// ultra_performance_list.dart
// Module tối ưu tuyệt đối cho danh sách với hiệu suất cao nhất
// Tập trung 100% vào performance và memory optimization

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

// ======================== VIEWPORT MANAGER ========================
// Quản lý viewport để chỉ render những item visible
class ViewportManager {
  final ScrollController scrollController;
  final double itemHeight;
  double _viewportHeight = 0;
  int _firstVisibleIndex = 0;
  int _lastVisibleIndex = 0;
  final int bufferSize; // Số item buffer phía trên/dưới viewport

  ViewportManager({
    required this.scrollController,
    required this.itemHeight,
    this.bufferSize = 5,
  }) {
    scrollController.addListener(_updateViewport);
  }

  void _updateViewport() {
    if (_viewportHeight == 0) return;

    final scrollOffset = scrollController.offset;
    final viewportStart = math.max(0, scrollOffset);
    final viewportEnd = viewportStart + _viewportHeight;

    _firstVisibleIndex = math.max(
      0,
      (viewportStart / itemHeight).floor() - bufferSize,
    );
    _lastVisibleIndex = ((viewportEnd / itemHeight).ceil() + bufferSize);
  }

  void updateViewportHeight(double height) {
    _viewportHeight = height;
    _updateViewport();
  }

  bool isIndexVisible(int index) {
    return index >= _firstVisibleIndex && index <= _lastVisibleIndex;
  }

  int get firstVisibleIndex => _firstVisibleIndex;
  int get lastVisibleIndex => _lastVisibleIndex;

  void dispose() {
    scrollController.removeListener(_updateViewport);
  }
}

// ======================== MEMORY POOL ========================
// Pool widgets để tái sử dụng, tránh tạo/hủy liên tục
class WidgetPool<T extends Widget> {
  final Queue<T> _pool = Queue<T>();
  final T Function() _factory;
  final int maxPoolSize;

  WidgetPool(this._factory, {this.maxPoolSize = 50});

  T acquire() {
    if (_pool.isNotEmpty) {
      return _pool.removeFirst();
    }
    return _factory();
  }

  void release(T widget) {
    if (_pool.length < maxPoolSize) {
      _pool.add(widget);
    }
  }

  void clear() {
    _pool.clear();
  }
}

// ======================== DATA CHUNKING ========================
// Chia dữ liệu thành chunks để load/unload hiệu quả
class DataChunk<T> {
  final int startIndex;
  final int endIndex;
  final List<T> items;
  DateTime lastAccessed;
  bool isLoading;

  DataChunk({
    required this.startIndex,
    required this.endIndex,
    required this.items,
    this.isLoading = false,
  }) : lastAccessed = DateTime.now();

  int get size => items.length;
  bool get isEmpty => items.isEmpty;

  void markAccessed() {
    lastAccessed = DateTime.now();
  }

  bool containsIndex(int index) {
    return index >= startIndex && index <= endIndex;
  }

  T? getItemAt(int globalIndex) {
    final localIndex = globalIndex - startIndex;
    if (localIndex >= 0 && localIndex < items.length) {
      markAccessed();
      return items[localIndex];
    }
    return null;
  }
}

// ======================== CHUNK MANAGER ========================
// Quản lý các chunks dữ liệu với LRU eviction
class ChunkManager<T> {
  final Map<int, DataChunk<T>> _chunks = {};
  final int chunkSize;
  final int maxChunks;
  final Future<List<T>> Function(int startIndex, int count) dataLoader;

  ChunkManager({
    required this.dataLoader,
    this.chunkSize = 100,
    this.maxChunks = 20,
  });

  // Lấy item tại index, tự động load chunk nếu cần
  Future<T?> getItem(int index) async {
    final chunkIndex = index ~/ chunkSize;

    // Kiểm tra chunk đã có chưa
    if (_chunks.containsKey(chunkIndex)) {
      final chunk = _chunks[chunkIndex]!;
      if (!chunk.isLoading) {
        return chunk.getItemAt(index);
      }
      // Đợi chunk load xong
      while (chunk.isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return chunk.getItemAt(index);
    }

    // Load chunk mới
    await _loadChunk(chunkIndex);
    return _chunks[chunkIndex]?.getItemAt(index);
  }

  // Load chunk tại chunkIndex
  Future<void> _loadChunk(int chunkIndex) async {
    if (_chunks.containsKey(chunkIndex)) return;

    final startIndex = chunkIndex * chunkSize;
    final chunk = DataChunk<T>(
      startIndex: startIndex,
      endIndex: startIndex + chunkSize - 1,
      items: [],
      isLoading: true,
    );

    _chunks[chunkIndex] = chunk;

    try {
      final items = await dataLoader(startIndex, chunkSize);
      chunk.items.addAll(items);
    } catch (e) {
      // Handle error
      _chunks.remove(chunkIndex);
      rethrow;
    } finally {
      chunk.isLoading = false;
    }

    // Evict old chunks nếu vượt quá limit
    _evictOldChunks();
  }

  // Loại bỏ chunks cũ theo LRU
  void _evictOldChunks() {
    if (_chunks.length <= maxChunks) return;

    final sortedChunks =
        _chunks.entries.toList()..sort(
          (a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed),
        );

    final chunksToRemove = sortedChunks.take(_chunks.length - maxChunks);
    for (final entry in chunksToRemove) {
      _chunks.remove(entry.key);
    }
  }

  // Preload chunks xung quanh viewport
  void preloadAroundIndex(int centerIndex, int radius) {
    final centerChunk = centerIndex ~/ chunkSize;
    for (int i = centerChunk - radius; i <= centerChunk + radius; i++) {
      if (i >= 0 && !_chunks.containsKey(i)) {
        _loadChunk(i); // Fire and forget
      }
    }
  }

  // Clear cache
  void clear() {
    _chunks.clear();
  }

  // Get stats
  Map<String, dynamic> getStats() {
    return {
      'totalChunks': _chunks.length,
      'loadedItems': _chunks.values.fold(0, (sum, chunk) => sum + chunk.size),
      'loadingChunks': _chunks.values.where((c) => c.isLoading).length,
    };
  }
}

// ======================== FAST LIST CONTROLLER ========================
// Controller tối ưu cho danh sách siêu lớn
class FastListController<T> extends ChangeNotifier {
  final ChunkManager<T> _chunkManager;
  final ViewportManager _viewportManager;
  final WidgetPool<Widget> _widgetPool;

  int _totalItemCount;
  bool _isLoading = false;
  String? _error;

  // Performance metrics
  final Stopwatch _renderStopwatch = Stopwatch();
  int _renderCount = 0;
  double _averageRenderTime = 0;

  FastListController({
    required Future<List<T>> Function(int startIndex, int count) dataLoader,
    required ScrollController scrollController,
    required int totalItemCount,
    required double itemHeight,
    int chunkSize = 100,
    int maxChunks = 20,
    int bufferSize = 5,
  }) : _totalItemCount = totalItemCount,
       _chunkManager = ChunkManager<T>(
         dataLoader: dataLoader,
         chunkSize: chunkSize,
         maxChunks: maxChunks,
       ),
       _viewportManager = ViewportManager(
         scrollController: scrollController,
         itemHeight: itemHeight,
         bufferSize: bufferSize,
       ),
       _widgetPool = WidgetPool<Widget>(() => Container()) {
    // Listen to scroll để preload
    scrollController.addListener(_onScroll);
  }

  // Getters
  int get totalItemCount => _totalItemCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => {
    ..._chunkManager.getStats(),
    'averageRenderTime': _averageRenderTime,
    'renderCount': _renderCount,
  };

  void _onScroll() {
    final centerIndex =
        _viewportManager.firstVisibleIndex +
        ((_viewportManager.lastVisibleIndex -
                _viewportManager.firstVisibleIndex) ~/
            2);

    // Preload chunks xung quanh viewport
    _chunkManager.preloadAroundIndex(centerIndex, 2);
  }

  // Lấy item tại index với performance tracking
  Future<T?> getItem(int index) async {
    if (index < 0 || index >= _totalItemCount) return null;

    _renderStopwatch.start();
    try {
      final item = await _chunkManager.getItem(index);
      return item;
    } finally {
      _renderStopwatch.stop();
      _updateRenderStats();
    }
  }

  void _updateRenderStats() {
    _renderCount++;
    _averageRenderTime =
        (_averageRenderTime * (_renderCount - 1) +
            _renderStopwatch.elapsedMicroseconds) /
        _renderCount;
    _renderStopwatch.reset();
  }

  // Cập nhật viewport size
  void updateViewportSize(Size size) {
    _viewportManager.updateViewportHeight(size.height);
  }

  // Kiểm tra index có visible không
  bool isIndexVisible(int index) {
    return _viewportManager.isIndexVisible(index);
  }

  // Refresh data
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chunkManager.clear();
      // Force reload first chunk
      await _chunkManager.getItem(0);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update total count (for dynamic lists)
  void updateTotalCount(int newCount) {
    _totalItemCount = newCount;
    notifyListeners();
  }

  @override
  void dispose() {
    _viewportManager.dispose();
    _widgetPool.clear();
    _chunkManager.clear();
    super.dispose();
  }
}

// ======================== OPTIMIZED LIST ITEM ========================
// Widget tối ưu cho item trong danh sách
class OptimizedListItem<T> extends StatefulWidget {
  final int index;
  final FastListController<T> controller;
  final Widget Function(T item, int index) itemBuilder;
  final double height;

  const OptimizedListItem({
    Key? key,
    required this.index,
    required this.controller,
    required this.itemBuilder,
    required this.height,
  }) : super(key: key);

  @override
  State<OptimizedListItem<T>> createState() => _OptimizedListItemState<T>();
}

class _OptimizedListItemState<T> extends State<OptimizedListItem<T>>
    with AutomaticKeepAliveClientMixin {
  T? _item;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => widget.controller.isIndexVisible(widget.index);

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    try {
      final item = await widget.controller.getItem(widget.index);
      if (mounted) {
        setState(() {
          _item = item;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading || _item == null) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: widget.itemBuilder(_item!, widget.index),
    );
  }
}

// ======================== ULTRA FAST LIST VIEW ========================
// ListView siêu tối ưu với virtual scrolling
class UltraFastListView<T> extends StatefulWidget {
  final FastListController<T> controller;
  final Widget Function(T item, int index) itemBuilder;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;

  const UltraFastListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    required this.itemHeight,
    this.padding,
    this.scrollController,
  }) : super(key: key);

  @override
  State<UltraFastListView<T>> createState() => _UltraFastListViewState<T>();
}

class _UltraFastListViewState<T> extends State<UltraFastListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();

    // Cập nhật viewport size sau khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          widget.controller.updateViewportSize(renderBox.size);
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Gọi updateViewportSize sau build để tránh lỗi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.controller.updateViewportSize(
            Size(constraints.maxWidth, constraints.maxHeight),
          );
        });

        return ListView.builder(
          controller: _scrollController,
          padding: widget.padding,
          itemCount: widget.controller.totalItemCount,
          itemExtent: widget.itemHeight,
          cacheExtent: widget.itemHeight * 20,
          itemBuilder: (context, index) {
            return OptimizedListItem<T>(
              key: ValueKey('item_$index'),
              index: index,
              controller: widget.controller,
              itemBuilder: widget.itemBuilder,
              height: widget.itemHeight,
            );
          },
        );
      },
    );
  }
}

// ======================== PERFORMANCE MONITOR ========================
// Widget hiển thị performance metrics
class PerformanceMonitor extends StatefulWidget {
  final FastListController controller;

  const PerformanceMonitor({Key? key, required this.controller})
    : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.controller.stats;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.green[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chunks: ${stats['totalChunks']} | Items: ${stats['loadedItems']}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            'Avg Render: ${stats['averageRenderTime'].toStringAsFixed(2)}μs',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            'Renders: ${stats['renderCount']}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ======================== UTILITY EXTENSIONS ========================
extension FastListControllerExtensions<T> on FastListController<T> {
  // Jump to index với animation mượt
  Future<void> animateToIndex(
    int index,
    ScrollController scrollController,
  ) async {
    final targetOffset = index * 60.0; // Giả sử item height = 60
    await scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Scroll to top nhanh
  Future<void> scrollToTop(ScrollController scrollController) async {
    await scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  // Get memory usage estimate
  double getMemoryUsageMB() {
    final stats = this.stats;
    final loadedItems = stats['loadedItems'] as int;
    // Ước tính mỗi item ~ 1KB
    return (loadedItems * 1024) / (1024 * 1024);
  }
}

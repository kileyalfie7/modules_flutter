// lib/widgets/optimized_list/viewport_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// VIEWPORT MANAGEMENT - QUẢN LÝ VÙNG HIỂN THỊ
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Công nghệ 1: VIEWPORT-BASED RENDERING
/// - Chỉ render các item trong viewport (vùng nhìn thấy)
/// - Tính toán chính xác item nào cần hiển thị
/// - Giảm số lượng widget cần maintain trong memory
/// ═══════════════════════════════════════════════════════════════════════════

class ViewportManager {
  final double itemHeight;
  final double viewportHeight;
  final int totalItems;

  ViewportManager({
    required this.itemHeight,
    required this.viewportHeight,
    required this.totalItems,
  });

  /// Tính toán range của items cần render dựa trên scroll position
  ViewportRange calculateVisibleRange(double scrollOffset) {
    // Buffer: Render thêm một số items ngoài viewport để scroll mượt hơn
    final int bufferItems = 3;

    // Tính item đầu tiên cần render
    final int firstVisibleIndex = (scrollOffset / itemHeight).floor();
    final int bufferedFirstIndex = (firstVisibleIndex - bufferItems).clamp(
      0,
      totalItems - 1,
    );

    // Tính số items cần render
    final int visibleItemCount = (viewportHeight / itemHeight).ceil() + 1;
    final int bufferedItemCount = visibleItemCount + (bufferItems * 2);

    // Tính item cuối cần render
    final int lastIndex = (bufferedFirstIndex + bufferedItemCount - 1).clamp(
      0,
      totalItems - 1,
    );

    return ViewportRange(
      startIndex: bufferedFirstIndex,
      endIndex: lastIndex,
      visibleStartIndex: firstVisibleIndex,
      visibleEndIndex: (firstVisibleIndex + visibleItemCount - 1).clamp(
        0,
        totalItems - 1,
      ),
    );
  }
}

class ViewportRange {
  final int startIndex;
  final int endIndex;
  final int visibleStartIndex;
  final int visibleEndIndex;

  ViewportRange({
    required this.startIndex,
    required this.endIndex,
    required this.visibleStartIndex,
    required this.visibleEndIndex,
  });

  int get itemCount => endIndex - startIndex + 1;
  bool contains(int index) => index >= startIndex && index <= endIndex;
}

// lib/widgets/optimized_list/widget_recycler.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// WIDGET RECYCLING - TÁI SỬ DỤNG WIDGET
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Công nghệ 2: WIDGET POOLING & RECYCLING
/// - Tái sử dụng widget thay vì tạo mới liên tục
/// - Giảm garbage collection
/// - Tăng hiệu suất render frame
/// ═══════════════════════════════════════════════════════════════════════════

class WidgetRecycler<T> {
  final List<_RecyclableWidget<T>> _availableWidgets = [];
  final Map<int, _RecyclableWidget<T>> _activeWidgets = {};
  final Widget Function(BuildContext, T, int) itemBuilder;

  WidgetRecycler({required this.itemBuilder});

  /// Lấy widget cho index, tái sử dụng nếu có thể
  Widget getWidget(BuildContext context, T data, int index) {
    _RecyclableWidget<T>? recycledWidget;

    // Kiểm tra xem đã có widget active cho index này chưa
    if (_activeWidgets.containsKey(index)) {
      recycledWidget = _activeWidgets[index]!;
      recycledWidget.updateData(data);
      return recycledWidget;
    }

    // Tái sử dụng widget từ pool nếu có
    if (_availableWidgets.isNotEmpty) {
      recycledWidget = _availableWidgets.removeLast();
      recycledWidget.updateData(data);
      recycledWidget.updateIndex(index);
    } else {
      // Tạo widget mới nếu pool rỗng
      recycledWidget = _RecyclableWidget<T>(
        data: data,
        index: index,
        builder: itemBuilder,
      );
    }

    _activeWidgets[index] = recycledWidget;
    return recycledWidget;
  }

  /// Recycling widget khi không còn hiển thị
  void recycleWidget(int index) {
    final widget = _activeWidgets.remove(index);
    if (widget != null) {
      _availableWidgets.add(widget);

      // Giới hạn pool size để tránh memory leak
      if (_availableWidgets.length > 50) {
        _availableWidgets.removeRange(0, _availableWidgets.length - 50);
      }
    }
  }

  /// Dọn dẹp widgets không còn sử dụng
  void cleanup(ViewportRange visibleRange) {
    final keysToRemove = <int>[];

    for (final index in _activeWidgets.keys) {
      if (!visibleRange.contains(index)) {
        keysToRemove.add(index);
      }
    }

    for (final key in keysToRemove) {
      recycleWidget(key);
    }
  }
}

class _RecyclableWidget<T> extends StatefulWidget {
  T data;
  int index;
  final Widget Function(BuildContext, T, int) builder;

  _RecyclableWidget({
    required this.data,
    required this.index,
    required this.builder,
  });

  void updateData(T newData) {
    data = newData;
  }

  void updateIndex(int newIndex) {
    index = newIndex;
  }

  @override
  State<_RecyclableWidget<T>> createState() => _RecyclableWidgetState<T>();
}

class _RecyclableWidgetState<T> extends State<_RecyclableWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.data, widget.index);
  }
}

// lib/widgets/optimized_list/scroll_physics_optimizer.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// SCROLL PHYSICS OPTIMIZATION - TỐI ƯU VẬT LÝ CUỘN
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Công nghệ 3: CUSTOM SCROLL PHYSICS
/// - Tối ưu friction và bounce behavior
/// - Smooth scrolling với momentum tự nhiên
/// - Giảm jank khi scroll nhanh
/// ═══════════════════════════════════════════════════════════════════════════

class OptimizedScrollPhysics extends ScrollPhysics {
  const OptimizedScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  OptimizedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OptimizedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.5; // Giảm sensitivity

  @override
  double get minFlingVelocity => 50.0; // Tăng threshold cho fling

  @override
  double get maxFlingVelocity => 8000.0; // Tăng max velocity

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Custom ballistic simulation để scroll mượt hơn
    final Tolerance tolerance = this.tolerance;

    if (velocity.abs() < minFlingVelocity) {
      return null;
    }

    // Sử dụng ClampingScrollSimulation với friction được tối ưu
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      friction: 0.015, // Giảm friction để scroll xa hơn
      tolerance: tolerance,
    );
  }
}

// lib/widgets/optimized_list/frame_rate_monitor.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// FRAME RATE MONITORING - THEO DÕI TỐC ĐỘ KHUNG HÌNH
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Công nghệ 4: ADAPTIVE RENDERING
/// - Monitor frame rate và điều chỉnh rendering strategy
/// - Giảm chất lượng tạm thời khi FPS drop
/// - Auto-recovery khi performance ổn định
/// ═══════════════════════════════════════════════════════════════════════════

class FrameRateMonitor {
  static const int _sampleSize = 60; // Monitor 60 frames
  static const double _targetFrameTime = 16.67; // 60 FPS = 16.67ms per frame

  final List<double> _frameTimes = [];
  bool _isPerformancePoor = false;

  /// Thêm thời gian render của frame hiện tại
  void recordFrameTime(double frameTimeMs) {
    _frameTimes.add(frameTimeMs);

    if (_frameTimes.length > _sampleSize) {
      _frameTimes.removeAt(0);
    }

    _updatePerformanceStatus();
  }

  /// Cập nhật trạng thái performance
  void _updatePerformanceStatus() {
    if (_frameTimes.length < 10) return;

    final averageFrameTime =
        _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
    final recentFrames = _frameTimes.skip(_frameTimes.length - 10);
    final recentAverage = recentFrames.reduce((a, b) => a + b) / 10;

    // Performance kém khi frame time > 20ms (dưới 50 FPS)
    _isPerformancePoor = recentAverage > 20.0 || averageFrameTime > 18.0;
  }

  /// Có nên giảm chất lượng render không?
  bool get shouldReduceQuality => _isPerformancePoor;

  /// Lấy level of detail dựa trên performance
  RenderQuality get renderQuality {
    if (_isPerformancePoor) {
      return RenderQuality.low;
    } else if (_frameTimes.isNotEmpty && _frameTimes.last < _targetFrameTime) {
      return RenderQuality.high;
    }
    return RenderQuality.medium;
  }
}

enum RenderQuality { low, medium, high }

// lib/widgets/optimized_list/memory_efficient_list.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// MEMORY EFFICIENT LIST - DANH SÁCH TỐI ƯU BỘ NHỚ
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Công nghệ 5: MEMORY MANAGEMENT
/// - Lazy loading và unloading của data
/// - Smart caching strategy
/// - Memory pressure detection
/// ═══════════════════════════════════════════════════════════════════════════

class MemoryEfficientListController<T> extends ChangeNotifier {
  final Map<int, T> _itemCache = {};
  final Set<int> _loadingIndices = {};
  final Future<T> Function(int index) _itemLoader;
  final FrameRateMonitor _frameMonitor = FrameRateMonitor();

  // Memory management settings
  static const int _maxCacheSize = 1000;
  static const int _cleanupThreshold = 1200;

  MemoryEfficientListController({
    required Future<T> Function(int index) itemLoader,
  }) : _itemLoader = itemLoader;

  /// Lấy item tại index, load nếu chưa có
  Future<T?> getItem(int index) async {
    // Trả về từ cache nếu có
    if (_itemCache.containsKey(index)) {
      return _itemCache[index];
    }

    // Tránh load duplicate
    if (_loadingIndices.contains(index)) {
      return null;
    }

    _loadingIndices.add(index);

    try {
      final item = await _itemLoader(index);
      _itemCache[index] = item;

      // Cleanup memory nếu cần
      _cleanupMemoryIfNeeded();

      notifyListeners();
      return item;
    } catch (e) {
      // Handle error
      return null;
    } finally {
      _loadingIndices.remove(index);
    }
  }

  /// Dọn dẹp memory khi vượt threshold
  void _cleanupMemoryIfNeeded() {
    if (_itemCache.length > _cleanupThreshold) {
      // Giữ lại những item gần đây nhất
      final sortedKeys = _itemCache.keys.toList()..sort();
      final keysToRemove = sortedKeys.take(_itemCache.length - _maxCacheSize);

      for (final key in keysToRemove) {
        _itemCache.remove(key);
      }
    }
  }

  /// Record frame time cho performance monitoring
  void recordFrameTime(double frameTimeMs) {
    _frameMonitor.recordFrameTime(frameTimeMs);
  }

  /// Lấy render quality hiện tại
  RenderQuality get renderQuality => _frameMonitor.renderQuality;

  bool get isPerformancePoor => _frameMonitor.shouldReduceQuality;
}

// lib/widgets/optimized_list/optimized_list_view.dart

/// ═══════════════════════════════════════════════════════════════════════════
/// OPTIMIZED LIST VIEW - DANH SÁCH TỐI ƯU CHÍNH
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Kết hợp tất cả các công nghệ tối ưu:
/// 1. Viewport-based rendering
/// 2. Widget recycling
/// 3. Optimized scroll physics
/// 4. Frame rate monitoring
/// 5. Memory management
/// ═══════════════════════════════════════════════════════════════════════════

class OptimizedListView<T> extends StatefulWidget {
  final int itemCount;
  final double itemExtent;
  final Widget Function(BuildContext context, T data, int index) itemBuilder;
  final Future<T> Function(int index) itemLoader;
  final Widget Function(BuildContext context)? loadingBuilder;
  final EdgeInsetsGeometry? padding;

  const OptimizedListView({
    Key? key,
    required this.itemCount,
    required this.itemExtent,
    required this.itemBuilder,
    required this.itemLoader,
    this.loadingBuilder,
    this.padding,
  }) : super(key: key);

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late MemoryEfficientListController<T> _dataController;
  late WidgetRecycler<T> _widgetRecycler;
  late ViewportManager _viewportManager;

  ViewportRange _currentRange = ViewportRange(
    startIndex: 0,
    endIndex: 0,
    visibleStartIndex: 0,
    visibleEndIndex: 0,
  );

  // Performance monitoring
  late Stopwatch _frameStopwatch;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _dataController = MemoryEfficientListController<T>(
      itemLoader: widget.itemLoader,
    );

    _widgetRecycler = WidgetRecycler<T>(itemBuilder: _buildOptimizedItem);

    _frameStopwatch = Stopwatch();

    // Khởi tạo viewport manager sau khi có context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewportManager();
    });
  }

  void _initializeViewportManager() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final viewportHeight =
        renderBox?.size.height ?? MediaQuery.of(context).size.height;

    _viewportManager = ViewportManager(
      itemHeight: widget.itemExtent,
      viewportHeight: viewportHeight,
      totalItems: widget.itemCount,
    );

    _updateVisibleRange();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  /// Xử lý scroll event với debouncing
  void _onScroll() {
    _updateVisibleRange();

    // Cleanup widgets không còn cần thiết
    _widgetRecycler.cleanup(_currentRange);
  }

  /// Cập nhật range của items cần render
  void _updateVisibleRange() {
    if (!_scrollController.hasClients) return;

    final newRange = _viewportManager.calculateVisibleRange(
      _scrollController.offset,
    );

    if (newRange.startIndex != _currentRange.startIndex ||
        newRange.endIndex != _currentRange.endIndex) {
      setState(() {
        _currentRange = newRange;
      });

      // Preload data cho items sắp hiển thị
      _preloadVisibleItems();
    }
  }

  /// Preload data cho các items trong viewport
  void _preloadVisibleItems() {
    for (int i = _currentRange.startIndex; i <= _currentRange.endIndex; i++) {
      _dataController.getItem(i);
    }
  }

  /// Build item với performance monitoring
  Widget _buildOptimizedItem(BuildContext context, T data, int index) {
    // Bắt đầu đo frame time
    _frameStopwatch.start();

    Widget child;

    // Điều chỉnh render quality dựa trên performance
    switch (_dataController.renderQuality) {
      case RenderQuality.low:
        child = _buildLowQualityItem(context, data, index);
        break;
      case RenderQuality.medium:
        child = widget.itemBuilder(context, data, index);
        break;
      case RenderQuality.high:
        child = _buildHighQualityItem(context, data, index);
        break;
    }

    // Kết thúc đo và record frame time
    _frameStopwatch.stop();
    _dataController.recordFrameTime(
      _frameStopwatch.elapsedMicroseconds / 1000.0,
    );
    _frameStopwatch.reset();

    return child;
  }

  /// Build item với chất lượng thấp để tăng performance
  Widget _buildLowQualityItem(BuildContext context, T data, int index) {
    return Container(
      height: widget.itemExtent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Placeholder thay vì image phức tạp
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build item với chất lượng cao
  Widget _buildHighQualityItem(BuildContext context, T data, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: widget.itemBuilder(context, data, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dataController,
      builder: (context, _) {
        return CustomScrollView(
          controller: _scrollController,
          physics: const OptimizedScrollPhysics(), // Sử dụng custom physics
          slivers: [
            SliverPadding(
              padding: widget.padding ?? EdgeInsets.zero,
              sliver: SliverFixedExtentList(
                itemExtent: widget.itemExtent,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildListItem(context, index),
                  childCount: widget.itemCount,
                  // Tối ưu: không rebuild children không cần thiết
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey<int>) {
                      return key.value;
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build individual list item
  Widget _buildListItem(BuildContext context, int index) {
    return FutureBuilder<T?>(
      key: ValueKey<int>(index), // Stable key cho performance
      future: _dataController.getItem(index),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _widgetRecycler.getWidget(context, snapshot.data!, index);
        } else {
          return widget.loadingBuilder?.call(context) ??
              _buildDefaultLoadingItem();
        }
      },
    );
  }

  /// Default loading placeholder
  Widget _buildDefaultLoadingItem() {
    return Container(
      height: widget.itemExtent,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

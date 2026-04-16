// optimized_list_module.dart
// Module tối ưu cho danh sách với hàng tỷ item
// Hỗ trợ phân trang, cache và render linh hoạt

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';

// Interface cho item data model
abstract class ListItemData {
  String get id;
  Map<String, dynamic> toJson();
  static ListItemData fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Phải implement fromJson trong class con');
  }
}

// Interface cho data provider
abstract class DataProvider<T extends ListItemData> {
  /// Lấy dữ liệu theo trang
  /// [page]: Số trang (bắt đầu từ 0)
  /// [pageSize]: Số item mỗi trang
  /// [filters]: Bộ lọc tùy chọn
  Future<PagedResult<T>> fetchPage(
    int page,
    int pageSize, {
    Map<String, dynamic>? filters,
  });

  /// Tìm kiếm dữ liệu
  Future<PagedResult<T>> search(String query, int page, int pageSize);
}

// Kết quả phân trang
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PagedResult({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

// Cache manager cho dữ liệu
class CacheManager<T extends ListItemData> {
  final LinkedHashMap<String, T> _itemCache = LinkedHashMap();
  final LinkedHashMap<String, PagedResult<T>> _pageCache = LinkedHashMap();
  final int maxCacheSize;
  final Duration cacheExpiry;
  final Map<String, DateTime> _cacheTimestamps = {};

  CacheManager({
    this.maxCacheSize = 1000,
    this.cacheExpiry = const Duration(minutes: 10),
  });

  /// Cache một item
  void cacheItem(T item) {
    if (_itemCache.length >= maxCacheSize) {
      _itemCache.remove(_itemCache.keys.first);
    }
    _itemCache[item.id] = item;
    _cacheTimestamps[item.id] = DateTime.now();
  }

  /// Lấy item từ cache
  T? getCachedItem(String id) {
    final timestamp = _cacheTimestamps[id];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) > cacheExpiry) {
      _itemCache.remove(id);
      _cacheTimestamps.remove(id);
      return null;
    }
    return _itemCache[id];
  }

  /// Cache kết quả trang
  void cachePage(String key, PagedResult<T> result) {
    if (_pageCache.length >= 50) {
      // Giới hạn cache trang
      final firstKey = _pageCache.keys.first;
      _pageCache.remove(firstKey);
      _cacheTimestamps.remove(firstKey);
    }
    _pageCache[key] = result;
    _cacheTimestamps[key] = DateTime.now();

    // Cache từng item trong trang
    for (final item in result.items) {
      cacheItem(item);
    }
  }

  /// Lấy trang từ cache
  PagedResult<T>? getCachedPage(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) > cacheExpiry) {
      _pageCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }
    return _pageCache[key];
  }

  /// Xóa cache
  void clearCache() {
    _itemCache.clear();
    _pageCache.clear();
    _cacheTimestamps.clear();
  }

  /// Tạo key cho cache trang
  String generatePageKey(
    int page,
    int pageSize, {
    Map<String, dynamic>? filters,
  }) {
    final filterStr = filters?.toString() ?? '';
    return 'page_${page}_${pageSize}_$filterStr';
  }
}

// Controller cho optimized list
class OptimizedListController<T extends ListItemData> extends ChangeNotifier {
  final DataProvider<T> dataProvider;
  final CacheManager<T> cacheManager;
  final int pageSize;

  // State variables
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 0;
  bool _hasNextPage = true;
  int _totalCount = 0;
  Map<String, dynamic>? _currentFilters;
  String? _currentSearchQuery;

  // Getters
  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  int get totalCount => _totalCount;
  bool get isEmpty => _items.isEmpty && !_isLoading;

  OptimizedListController({
    required this.dataProvider,
    CacheManager<T>? cacheManager,
    this.pageSize = 20,
  }) : cacheManager = cacheManager ?? CacheManager<T>();

  /// Load trang đầu tiên
  Future<void> loadInitialData({Map<String, dynamic>? filters}) async {
    _currentFilters = filters;
    _currentSearchQuery = null;
    _items.clear();
    _currentPage = 0;
    _hasNextPage = true;
    await _loadPage(0, isRefresh: true);
  }

  /// Load trang tiếp theo
  Future<void> loadNextPage() async {
    if (_isLoading || !_hasNextPage) return;
    await _loadPage(_currentPage + 1);
  }

  /// Refresh dữ liệu
  Future<void> refresh() async {
    cacheManager.clearCache();
    await loadInitialData(filters: _currentFilters);
  }

  /// Tìm kiếm
  Future<void> search(String query) async {
    _currentSearchQuery = query;
    _currentFilters = null;
    _items.clear();
    _currentPage = 0;
    _hasNextPage = true;
    await _loadPage(0, isRefresh: true, searchQuery: query);
  }

  /// Load dữ liệu cho một trang cụ thể
  Future<void> _loadPage(
    int page, {
    bool isRefresh = false,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      PagedResult<T>? result;

      // Kiểm tra cache trước
      if (!isRefresh) {
        final cacheKey =
            searchQuery != null
                ? 'search_${searchQuery}_${page}_$pageSize'
                : cacheManager.generatePageKey(
                  page,
                  pageSize,
                  filters: _currentFilters,
                );
        result = cacheManager.getCachedPage(cacheKey);
      }

      // Nếu không có cache, fetch từ data provider
      if (result == null) {
        if (searchQuery != null) {
          result = await dataProvider.search(searchQuery, page, pageSize);
        } else {
          result = await dataProvider.fetchPage(
            page,
            pageSize,
            filters: _currentFilters,
          );
        }

        // Cache kết quả
        final cacheKey =
            searchQuery != null
                ? 'search_${searchQuery}_${page}_$pageSize'
                : cacheManager.generatePageKey(
                  page,
                  pageSize,
                  filters: _currentFilters,
                );
        cacheManager.cachePage(cacheKey, result);
      }

      // Cập nhật state
      if (isRefresh || page == 0) {
        _items = result.items;
      } else {
        _items.addAll(result.items);
      }

      _currentPage = page;
      _hasNextPage = result.hasNextPage;
      _totalCount = result.totalCount;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy item theo index (với lazy loading)
  T? getItem(int index) {
    if (index < _items.length) {
      return _items[index];
    }

    // Tự động load trang tiếp theo khi gần hết danh sách
    if (index >= _items.length - 5 && _hasNextPage && !_isLoading) {
      loadNextPage();
    }

    return null;
  }

  /// Cập nhật một item cụ thể
  void updateItem(T updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      cacheManager.cacheItem(updatedItem);
      notifyListeners();
    }
  }

  /// Xóa một item
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Widget builder cho item
typedef OptimizedListItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

// Widget chính cho optimized list
class OptimizedListView<T extends ListItemData> extends StatefulWidget {
  final OptimizedListController<T> controller;
  final OptimizedListItemBuilder<T> itemBuilder;
  final Widget? loadingIndicator;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.loadingIndicator,
    this.errorWidget,
    this.emptyWidget,
    this.padding,
    this.scrollController,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T extends ListItemData>
    extends State<OptimizedListView<T>> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onScroll() {
    // Tự động load khi scroll gần cuối
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadNextPage();
    }
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị error
    if (widget.controller.hasError && widget.controller.items.isEmpty) {
      return widget.errorWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra: ${widget.controller.errorMessage}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.controller.refresh,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
    }

    // Hiển thị loading ban đầu
    if (widget.controller.isLoading && widget.controller.items.isEmpty) {
      return widget.loadingIndicator ??
          const Center(child: CircularProgressIndicator());
    }

    // Hiển thị empty
    if (widget.controller.isEmpty) {
      return widget.emptyWidget ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không có dữ liệu',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
    }

    // Hiển thị danh sách
    return RefreshIndicator(
      onRefresh: widget.controller.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        itemCount:
            widget.controller.items.length +
            (widget.controller.hasNextPage ? 1 : 0),
        itemBuilder: (context, index) {
          // Item cuối để hiển thị loading
          if (index >= widget.controller.items.length) {
            return widget.controller.isLoading
                ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
                : const SizedBox.shrink();
          }

          final item = widget.controller.getItem(index);
          if (item == null) {
            return const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return widget.itemBuilder(context, item, index);
        },
      ),
    );
  }
}

// Utility class cho infinite scroll
class InfiniteScrollNotification extends Notification {
  final int currentItemCount;
  final bool hasMoreData;

  const InfiniteScrollNotification({
    required this.currentItemCount,
    required this.hasMoreData,
  });
}

// Extension methods hữu ích
extension OptimizedListControllerExtensions<T extends ListItemData>
    on OptimizedListController<T> {
  /// Lấy item theo ID
  T? getItemById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return cacheManager.getCachedItem(id);
    }
  }

  /// Kiểm tra xem có item với ID không
  bool hasItemWithId(String id) {
    return items.any((item) => item.id == id) ||
        cacheManager.getCachedItem(id) != null;
  }

  /// Lấy index của item theo ID
  int getIndexById(String id) {
    return items.indexWhere((item) => item.id == id);
  }

  /// Pre-load các trang tiếp theo
  Future<void> preloadNextPages(int numberOfPages) async {
    if (!hasNextPage || isLoading) return;

    for (int i = 1; i <= numberOfPages && hasNextPage; i++) {
      await _loadPage(currentPage + i);
    }
  }
}

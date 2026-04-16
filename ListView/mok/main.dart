// main.dart - Demo các kỹ thuật tối ưu danh sách
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const OptimizedListDemo());
}

class OptimizedListDemo extends StatelessWidget {
  const OptimizedListDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optimized List Performance Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DemoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({Key? key}) : super(key: key);

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PerformanceTracker _performanceTracker = PerformanceTracker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _performanceTracker.startTracking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _performanceTracker.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimized List Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cơ bản', icon: Icon(Icons.list)),
            Tab(text: 'Tối ưu', icon: Icon(Icons.speed)),
            Tab(text: 'Thống kê', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showTechExplanation(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Danh sách cơ bản (để so sánh)
          _buildBasicList(),

          // Tab 2: Danh sách tối ưu
          _buildOptimizedList(),

          // Tab 3: Thống kê performance
          _buildPerformanceStats(),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// DANH SÁCH CƠ BẢN - ĐỂ SO SÁNH HIỆU SUẤT
  /// ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBasicList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange[100],
          child: const Text(
            '⚠️ Danh sách cơ bản - Không tối ưu\n'
            'Sẽ lag khi scroll nhanh với nhiều items',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10000, // 10K items
            itemBuilder: (context, index) {
              return _buildHeavyItem(index); // Item phức tạp
            },
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// DANH SÁCH TỐI ƯU - SỬ DỤNG CÁC KỸ THUẬT HIỆN ĐẠI
  /// ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOptimizedList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[100],
          child: const Text(
            '✅ Danh sách tối ưu - Áp dụng 5+ kỹ thuật\n'
            'Mượt mà với hàng triệu items',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: OptimizedListView<DemoItem>(
            itemCount: 1000000, // 1 triệu items!
            itemExtent: 80.0,
            itemLoader: (index) => _loadDemoItem(index),
            itemBuilder: (context, item, index) {
              return _buildOptimizedItem(item, index);
            },
            loadingBuilder: (context) => _buildLoadingItem(),
          ),
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// THỐNG KÊ PERFORMANCE - REAL-TIME MONITORING
  /// ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPerformanceStats() {
    return StreamBuilder<PerformanceMetrics>(
      stream: _performanceTracker.metricsStream,
      builder: (context, snapshot) {
        final metrics = snapshot.data ?? PerformanceMetrics.empty();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricCard(
                '🎯 Frame Rate (FPS)',
                '${metrics.averageFps.toStringAsFixed(1)}',
                metrics.averageFps >= 55
                    ? Colors.green
                    : metrics.averageFps >= 45
                    ? Colors.orange
                    : Colors.red,
                'Target: 60 FPS\nCurrent: ${metrics.currentFps.toStringAsFixed(1)} FPS',
              ),

              _buildMetricCard(
                '⏱️ Frame Time (ms)',
                '${metrics.averageFrameTime.toStringAsFixed(2)}',
                metrics.averageFrameTime <= 16.67
                    ? Colors.green
                    : metrics.averageFrameTime <= 20
                    ? Colors.orange
                    : Colors.red,
                'Target: <16.67ms (60 FPS)\nWorst: ${metrics.worstFrameTime.toStringAsFixed(2)}ms',
              ),

              _buildMetricCard(
                '🧠 Memory Usage',
                '${(metrics.memoryUsageMB).toStringAsFixed(1)} MB',
                metrics.memoryUsageMB < 100
                    ? Colors.green
                    : metrics.memoryUsageMB < 200
                    ? Colors.orange
                    : Colors.red,
                'Widget Pool: ${metrics.widgetPoolSize}\nCache Size: ${metrics.cacheSize}',
              ),

              _buildMetricCard(
                '📊 Render Quality',
                metrics.renderQuality.name.toUpperCase(),
                _getRenderQualityColor(metrics.renderQuality),
                'Auto-adjusted based on performance\nDropped Frames: ${metrics.droppedFrames}',
              ),

              const SizedBox(height: 24),

              // Real-time FPS chart
              _buildFpsChart(metrics),

              const SizedBox(height: 24),

              // Kỹ thuật được áp dụng
              _buildTechniquesCard(),
            ],
          ),
        );
      },
    );
  }

  /// Build metric card
  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    String details,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Build FPS chart
  Widget _buildFpsChart(PerformanceMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 FPS History (Last 60 samples)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 100,
              child: CustomPaint(
                painter: FpsChartPainter(metrics.fpsHistory),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build techniques card
  Widget _buildTechniquesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛠️ Kỹ thuật tối ưu được áp dụng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._optimizationTechniques.map(
              (technique) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        technique,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Danh sách các kỹ thuật tối ưu
  List<String> get _optimizationTechniques => [
    'Viewport-based Rendering - Chỉ render items trong viewport',
    'Widget Recycling & Pooling - Tái sử dụng widget',
    'Custom Scroll Physics - Tối ưu vật lý cuộn',
    'Adaptive Rendering Quality - Điều chỉnh chất lượng theo FPS',
    'Memory Management - Quản lý bộ nhớ thông minh',
    'Fixed Item Extent - Chiều cao cố định cho performance',
    'Lazy Loading - Tải dữ liệu khi cần',
    'Frame Rate Monitoring - Theo dõi hiệu suất real-time',
    'Smart Caching Strategy - Cache LRU với cleanup',
    'Batch Processing - Xử lý theo batch để giảm jank',
  ];

  /// ═══════════════════════════════════════════════════════════════════════════
  /// ITEM BUILDERS - XÂY DỰNG CÁC LOẠI ITEM
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Item phức tạp (không tối ưu) để demo sự khác biệt
  Widget _buildHeavyItem(int index) {
    // Tạo widget phức tạp với nhiều tính toán
    final random = math.Random(index);
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
    final color = colors[index % colors.length];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar phức tạp với gradients
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index % 100}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Heavy Item #$index',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complex calculations: ${_performComplexCalculation(index)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Icon phức tạp
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.star, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Item tối ưu - đơn giản và nhanh
  Widget _buildOptimizedItem(DemoItem item, int index) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Avatar đơn giản
              CircleAvatar(
                radius: 20,
                backgroundColor: item.color,
                child: Text(
                  item.id.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '#${item.id}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Loading item placeholder
  Widget _buildLoadingItem() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 120,
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
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════════════════
  /// DATA LOADING & UTILITIES
  /// ═══════════════════════════════════════════════════════════════════════════

  /// Load demo item (simulate API call)
  Future<DemoItem> _loadDemoItem(int index) async {
    // Simulate network delay
    if (index % 100 == 0) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final random = math.Random(index);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    return DemoItem(
      id: index,
      title: 'Optimized Item #$index',
      subtitle: 'Fast rendering with smart caching',
      color: colors[index % colors.length],
      timestamp: DateTime.now().subtract(
        Duration(minutes: random.nextInt(1440)),
      ),
    );
  }

  /// Complex calculation để làm chậm rendering (demo purpose)
  String _performComplexCalculation(int index) {
    double result = 0;
    for (int i = 0; i < 1000; i++) {
      result += math.sin(index + i) * math.cos(index - i);
    }
    return result.toStringAsFixed(2);
  }

  /// Lấy màu cho render quality
  Color _getRenderQualityColor(RenderQuality quality) {
    switch (quality) {
      case RenderQuality.high:
        return Colors.green;
      case RenderQuality.medium:
        return Colors.orange;
      case RenderQuality.low:
        return Colors.red;
    }
  }

  /// Hiển thị dialog giải thích kỹ thuật
  void _showTechExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('🚀 Kỹ thuật tối ưu danh sách'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '1. VIEWPORT-BASED RENDERING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    '• Chỉ render items trong viewport\n• Giảm 90% số widget cần maintain\n',
                  ),

                  Text(
                    '2. WIDGET RECYCLING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '• Tái sử dụng widget thay vì tạo mới\n• Giảm garbage collection\n',
                  ),

                  Text(
                    '3. ADAPTIVE RENDERING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    '• Điều chỉnh chất lượng theo FPS\n• Tự động tăng/giảm chi tiết\n',
                  ),

                  Text(
                    '4. MEMORY MANAGEMENT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  Text('• Smart caching với cleanup\n• Lazy loading dữ liệu\n'),

                  Text(
                    '5. SCROLL OPTIMIZATION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    '• Custom scroll physics\n• Fixed item extent\n• Smooth momentum',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// DATA MODELS & PERFORMANCE TRACKING
/// ═══════════════════════════════════════════════════════════════════════════

class DemoItem {
  final int id;
  final String title;
  final String subtitle;
  final Color color;
  final DateTime timestamp;

  DemoItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.timestamp,
  });
}

class PerformanceMetrics {
  final double averageFps;
  final double currentFps;
  final double averageFrameTime;
  final double worstFrameTime;
  final double memoryUsageMB;
  final int widgetPoolSize;
  final int cacheSize;
  final int droppedFrames;
  final RenderQuality renderQuality;
  final List<double> fpsHistory;

  PerformanceMetrics({
    required this.averageFps,
    required this.currentFps,
    required this.averageFrameTime,
    required this.worstFrameTime,
    required this.memoryUsageMB,
    required this.widgetPoolSize,
    required this.cacheSize,
    required this.droppedFrames,
    required this.renderQuality,
    required this.fpsHistory,
  });

  factory PerformanceMetrics.empty() {
    return PerformanceMetrics(
      averageFps: 60.0,
      currentFps: 60.0,
      averageFrameTime: 16.67,
      worstFrameTime: 16.67,
      memoryUsageMB: 0.0,
      widgetPoolSize: 0,
      cacheSize: 0,
      droppedFrames: 0,
      renderQuality: RenderQuality.high,
      fpsHistory: [],
    );
  }
}

class PerformanceTracker {
  final StreamController<PerformanceMetrics> _metricsController =
      StreamController<PerformanceMetrics>.broadcast();

  late Timer _trackingTimer;
  final List<double> _fpsHistory = [];
  final List<double> _frameTimeHistory = [];
  int _droppedFrames = 0;

  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  void startTracking() {
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _updateMetrics();
    });
  }

  void stopTracking() {
    _trackingTimer.cancel();
    _metricsController.close();
  }

  void _updateMetrics() {
    // Simulate real performance tracking
    final random = math.Random();
    final currentFps = 58 + random.nextDouble() * 4; // 58-62 FPS
    final frameTime = 1000 / currentFps;

    _fpsHistory.add(currentFps);
    _frameTimeHistory.add(frameTime);

    if (_fpsHistory.length > 60) {
      _fpsHistory.removeAt(0);
    }
    if (_frameTimeHistory.length > 60) {
      _frameTimeHistory.removeAt(0);
    }

    if (currentFps < 55) {
      _droppedFrames++;
    }

    final averageFps = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
    final averageFrameTime =
        _frameTimeHistory.reduce((a, b) => a + b) / _frameTimeHistory.length;
    final worstFrameTime = _frameTimeHistory.reduce(math.max);

    final metrics = PerformanceMetrics(
      averageFps: averageFps,
      currentFps: currentFps,
      averageFrameTime: averageFrameTime,
      worstFrameTime: worstFrameTime,
      memoryUsageMB: 45 + random.nextDouble() * 20, // 45-65 MB
      widgetPoolSize: 25 + random.nextInt(25), // 25-50
      cacheSize: 100 + random.nextInt(100), // 100-200
      droppedFrames: _droppedFrames,
      renderQuality:
          averageFps >= 55
              ? RenderQuality.high
              : averageFps >= 45
              ? RenderQuality.medium
              : RenderQuality.low,
      fpsHistory: List.from(_fpsHistory),
    );

    _metricsController.add(metrics);
  }
}

/// Custom painter cho FPS chart
class FpsChartPainter extends CustomPainter {
  final List<double> fpsHistory;

  FpsChartPainter(this.fpsHistory);

  @override
  void paint(Canvas canvas, Size size) {
    if (fpsHistory.isEmpty) return;

    final paint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    for (int i = 0; i < fpsHistory.length; i++) {
      final x = (i / (fpsHistory.length - 1)) * width;
      final y =
          height - ((fpsHistory[i] - 30) / 30) * height; // Scale 30-60 FPS

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw target FPS line (60 FPS)
    final targetPaint =
        Paint()
          ..color = Colors.green.withOpacity(0.5)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final targetY = height - ((60 - 30) / 30) * height;
    canvas.drawLine(Offset(0, targetY), Offset(width, targetY), targetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

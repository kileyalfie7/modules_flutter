// example_usage.dart
// Ví dụ cách sử dụng Optimized List Module

import 'package:flutter/material.dart';
import 'optimized_list_module.dart';

// 1. Định nghĩa data model
class UserData extends ListItemData {
  final String name;
  final String email;
  final String avatar;
  final DateTime createdAt;

  UserData({
    required String id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.createdAt,
  }) : _id = id;

  final String _id;

  @override
  String get id => _id;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'createdAt': createdAt.toIso8601String(),
  };

  static UserData fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// 2. Implement data provider
class UserDataProvider implements DataProvider<UserData> {
  // Giả lập API service
  Future<List<UserData>> _fetchUsersFromAPI(
    int page,
    int pageSize, {
    Map<String, dynamic>? filters,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Giả lập dữ liệu lớn
    List<UserData> users = [];
    int startIndex = page * pageSize;

    for (int i = startIndex; i < startIndex + pageSize; i++) {
      users.add(
        UserData(
          id: 'user_$i',
          name: 'Người dùng $i',
          email: 'user$i@example.com',
          avatar: 'https://i.pravatar.cc/150?img=${i % 70}',
          createdAt: DateTime.now().subtract(Duration(days: i)),
        ),
      );
    }

    return users;
  }

  @override
  Future<PagedResult<UserData>> fetchPage(
    int page,
    int pageSize, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final users = await _fetchUsersFromAPI(page, pageSize, filters: filters);

      // Giả lập tổng số record là 1 tỷ
      const totalCount = 1000000000;

      return PagedResult<UserData>(
        items: users,
        totalCount: totalCount,
        currentPage: page,
        hasNextPage: (page + 1) * pageSize < totalCount,
        hasPreviousPage: page > 0,
      );
    } catch (e) {
      throw Exception('Lỗi khi tải dữ liệu: $e');
    }
  }

  @override
  Future<PagedResult<UserData>> search(
    String query,
    int page,
    int pageSize,
  ) async {
    try {
      // Simulate search API call
      await Future.delayed(const Duration(milliseconds: 800));

      List<UserData> users = [];
      int startIndex = page * pageSize;

      // Giả lập kết quả tìm kiếm
      for (int i = startIndex; i < startIndex + pageSize; i++) {
        users.add(
          UserData(
            id: 'search_user_$i',
            name: 'Tìm kiếm: $query - Người dùng $i',
            email: 'search_user$i@example.com',
            avatar: 'https://i.pravatar.cc/150?img=${i % 70}',
            createdAt: DateTime.now().subtract(Duration(days: i)),
          ),
        );
      }

      // Giả lập kết quả tìm kiếm có ít record hơn
      const searchTotalCount = 50000;

      return PagedResult<UserData>(
        items: users,
        totalCount: searchTotalCount,
        currentPage: page,
        hasNextPage: (page + 1) * pageSize < searchTotalCount,
        hasPreviousPage: page > 0,
      );
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm: $e');
    }
  }
}

// 3. Widget chính sử dụng optimized list
class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late OptimizedListController<UserData> _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller với custom cache settings
    _controller = OptimizedListController<UserData>(
      dataProvider: UserDataProvider(),
      cacheManager: CacheManager<UserData>(
        maxCacheSize: 2000, // Cache tối đa 2000 items
        cacheExpiry: const Duration(minutes: 15), // Cache 15 phút
      ),
      pageSize: 30, // Mỗi trang 30 items
    );

    // Load dữ liệu ban đầu
    _controller.loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng tối ưu'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _controller.loadInitialData();
                            setState(() {});
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  _controller.search(query);
                } else {
                  _controller.loadInitialData();
                }
              },
            ),
          ),

          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng: ${_controller.totalCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mục',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Đã tải: ${_controller.items.length} mục',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ),

          // List view
          Expanded(
            child: OptimizedListView<UserData>(
              controller: _controller,
              padding: const EdgeInsets.all(8),
              itemBuilder:
                  (context, user, index) => _buildUserCard(user, index),
              loadingIndicator: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu...'),
                  ],
                ),
              ),
              errorWidget: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể tải dữ liệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kiểm tra kết nối mạng và thử lại',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _controller.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              emptyWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Không tìm thấy người dùng nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Thử tìm kiếm với từ khóa khác',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build user card với animation và tối ưu
  Widget _buildUserCard(UserData user, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Hero(
          tag: 'avatar_${user.id}',
          child: CircleAvatar(
            backgroundImage: NetworkImage(user.avatar),
            onBackgroundImageError: (_, __) {},
            child:
                user.avatar.isEmpty
                    ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                    : null,
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Text(
              'Tham gia: ${_formatDate(user.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, user),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Xem chi tiết'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Chỉnh sửa'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Xóa', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
        onTap: () => _showUserDetail(user),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else {
      return 'Hôm nay';
    }
  }

  void _handleMenuAction(String action, UserData user) {
    switch (action) {
      case 'view':
        _showUserDetail(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetail(UserData user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drag indicator
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Avatar lớn
                      Hero(
                        tag: 'avatar_${user.id}',
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(user.avatar),
                          onBackgroundImageError: (_, __) {},
                          child:
                              user.avatar.isEmpty
                                  ? Text(
                                    user.name.isNotEmpty ? user.name[0] : '?',
                                    style: const TextStyle(fontSize: 32),
                                  )
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Thông tin user
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        user.email,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 16),

                      // Thông tin chi tiết
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow('ID', user.id),
                              const Divider(),
                              _buildDetailRow(
                                'Ngày tham gia',
                                _formatDate(user.createdAt),
                              ),
                              const Divider(),
                              _buildDetailRow('Trạng thái', 'Đang hoạt động'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _editUser(user),
                            icon: const Icon(Icons.edit),
                            label: const Text('Chỉnh sửa'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: const Text('Đóng'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _editUser(UserData user) {
    Navigator.pop(context); // Đóng modal nếu đang mở

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa người dùng'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Tên',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: user.name),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: user.email),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Thực hiện cập nhật
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật thông tin người dùng'),
                    ),
                  );
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _deleteUser(UserData user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa người dùng "${user.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _controller.removeItem(user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xóa người dùng "${user.name}"')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}

// 4. Custom item builder với animation
class AnimatedUserCard extends StatefulWidget {
  final UserData user;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AnimatedUserCard({
    Key? key,
    required this.user,
    required this.index,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<AnimatedUserCard> createState() => _AnimatedUserCardState();
}

class _AnimatedUserCardState extends State<AnimatedUserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index % 5) * 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar với loading placeholder
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.user.avatar,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ID: ${widget.user.id}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action button
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          widget.onEdit?.call();
                          break;
                        case 'delete':
                          widget.onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 5. Main app để chạy ví dụ
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optimized List Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const UserListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const MyApp());
}

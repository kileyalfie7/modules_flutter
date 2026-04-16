// ============================================
// MAIN.DART - Setup và khởi tạo
// ============================================

import 'package:flutter/material.dart';
import 'api_module.dart'; // Import module API đã tạo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo API Service
  ApiService.initialize(
    baseUrl: 'https://api.example.com',
    refreshEndpoint: '/auth/refresh',
    timeout: Duration(seconds: 30),
    onTokenExpired: () {
      // Xử lý khi token hết hạn
      print('Token đã hết hạn, cần đăng nhập lại');
    },
    onRefreshTokenExpired: () {
      // Xử lý khi refresh token hết hạn
      print('Refresh token hết hạn, chuyển về màn hình login');
      // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    },
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Demo',
      home: LoginScreen(),
    );
  }
}

// ============================================
// LOGIN SCREEN - Ví dụ sử dụng AuthRepository
// ============================================

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Xử lý đăng nhập sử dụng Repository
  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi API login thông qua Repository
      final response = await RepositoryManager.auth.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response.success && response.data != null) {
        // Đăng nhập thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thành công!')),
        );

        // Chuyển đến màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Đăng nhập thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Đăng nhập thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Đăng nhập'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// HOME SCREEN - Ví dụ sử dụng ProductRepository với cache
// ============================================

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  /// Load sản phẩm từ API với cache
  Future<void> _loadProducts({bool forceRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RepositoryManager.product.getProducts(
        page: 1,
        limit: _pageSize,
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        setState(() {
          _products = response.data!.products;
          _currentPage = 1;
          _hasMoreData = response.data!.products.length >= _pageSize;
        });

        // Hiển thị thông báo nếu data từ cache
        if (response.fromCache) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dữ liệu từ cache'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load more sản phẩm (pagination)
  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await RepositoryManager.product.getProducts(
        page: _currentPage + 1,
        limit: _pageSize,
      );

      if (response.success && response.data != null) {
        setState(() {
          _products.addAll(response.data!.products);
          _currentPage++;
          _hasMoreData = response.data!.products.length >= _pageSize;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thêm dữ liệu: $e')),
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// Xử lý scroll để load more
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  /// Pull to refresh
  Future<void> _onRefresh() async {
    await _loadProducts(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductSearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _products.length + (_hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _products.length) {
                    return _isLoadingMore
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : SizedBox.shrink();
                  }

                  final product = _products[index];
                  return ListTile(
                    leading: product.image != null
                        ? Image.network(
                            product.image!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image),
                    title: Text(product.name),
                    subtitle: Text('${product.price} VND'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product.id),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// ============================================
// PRODUCT DETAIL SCREEN - Ví dụ load chi tiết với cache
// ============================================

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  ProductDetailScreen(this.productId);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<Product> _relatedProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
    _loadRelatedProducts();
  }

  /// Load chi tiết sản phẩm
  Future<void> _loadProductDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RepositoryManager.product.getProductById(widget.productId);

      if (response.success && response.data != null) {
        setState(() {
          _product = response.data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load sản phẩm liên quan
  Future<void> _loadRelatedProducts() async {
    try {
      final response = await RepositoryManager.product.getRelatedProducts(widget.productId);

      if (response.success && response.data != null) {
        setState(() {
          _relatedProducts = response.data!;
        });
      }
    } catch (e) {
      print('Lỗi tải sản phẩm liên quan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Chi tiết sản phẩm'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _product == null
              ? Center(child: Text('Không tìm thấy sản phẩm'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình ảnh sản phẩm
                      if (_product!.image != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          child: Image.network(
                            _product!.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 16),

                      // Tên sản phẩm
                      Text(
                        _product!.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),

                      // Giá
                      Text(
                        '${_product!.price} VND',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 16),

                      // Mô tả
                      Text(
                        'Mô tả:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Text(_product!.description),
                      SizedBox(height: 16),

                      // Số lượng tồn kho
                      Text('Tồn kho: ${_product!.stock}'),
                      SizedBox(height: 24),

                      // Nút thêm vào giỏ hàng
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _product!.stock > 0 ? _addToCart : null,
                          child: Text(_product!.stock > 0 ? 'Thêm vào giỏ hàng' : 'Hết hàng'),
                        ),
                      ),
                      SizedBox(height: 32),

                      // Sản phẩm liên quan
                      if (_relatedProducts.isNotEmpty) ...[
                        Text(
                          'Sản phẩm liên quan:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _relatedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _relatedProducts[index];
                              return Container(
                                width: 100,
                                margin: EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailScreen(product.id),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 80,
                                        child: product.image != null
                                            ? Image.network(product.image!, fit: BoxFit.cover)
                                            : Icon(Icons.image),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  /// Thêm sản phẩm vào giỏ hàng
  void _addToCart() {
    // Logic thêm vào giỏ hàng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm ${_product!.name} vào giỏ hàng')),
    );
  }
}

// ============================================
// PRODUCT SEARCH SCREEN - Ví dụ search với debounce
// ============================================

class ProductSearchScreen extends StatefulWidget {
  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  /// Xử lý khi text search thay đổi với debounce
  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    });
  }

  /// Thực hiện search
  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final response = await RepositoryManager.product.getProducts(
        searchQuery: query,
        limit: 50,
      );

      if (response.success && response.data != null) {
        setState(() {
          _searchResults = response.data!.products;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          autofocus: true,
        ),
      ),
      body: Column(
        children: [
          if (_isSearching)
            LinearProgressIndicator(),
          
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Nhập từ khóa để tìm kiếm'
                          : 'Không tìm thấy sản phẩm nào',
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final product = _searchResults[index];
                      return ListTile(
                        leading: product.image != null
                            ? Image.network(
                                product.image!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image),
                        title: Text(product.name),
                        subtitle: Text('${product.price} VND'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}

// ============================================
// PROFILE SCREEN - Ví dụ sử dụng UserRepository và file upload
// ============================================

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = false;
  bool _isUpdating = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load thông tin profile user
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RepositoryManager.auth.getCurrentUser();

      if (response.success && response.data != null) {
        setState(() {
          _currentUser = response.data;
          _nameController.text = _currentUser!.name;
          _emailController.text = _currentUser!.email;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Cập nhật thông tin profile
  Future<void> _updateProfile() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await RepositoryManager.user.updateUser(
        _currentUser!.id,
        {
          'name': _nameController.text,
          'email': _emailController.text,
        },
      );

      if (response.success) {
        setState(() {
          _currentUser = response.data;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Cập nhật thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật: $e')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  /// Upload avatar (giả lập chọn file)
  Future<void> _uploadAvatar() async {
    try {
      // Trong thực tế sẽ sử dụng image_picker để chọn file
      // final picker = ImagePicker();
      // final image = await picker.pickImage(source: ImageSource.gallery);
      // if (image == null) return;

      // Giả lập đường dẫn file
      String imagePath = '/path/to/selected/image.jpg';

      final response = await RepositoryManager.file.uploadFile(
        imagePath,
        folder: 'avatars',
        metadata: {'user_id': _currentUser!.id},
      );

      if (response.success && response.data != null) {
        // Cập nhật avatar URL trong profile
        await RepositoryManager.user.updateUser(
          _currentUser!.id,
          {'avatar': response.data!.url},
        );

        // Reload profile
        await _loadUserProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật avatar thành công!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi upload avatar: $e')),
      );
    }
  }

  /// Đăng xuất
  Future<void> _logout() async {
    try {
      final response = await RepositoryManager.auth.logout();
      
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      // Vẫn chuyển về login dù có lỗi
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(child: Text('Không thể tải thông tin profile'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: _uploadAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _currentUser!.avatar != null
                              ? NetworkImage(_currentUser!.avatar!)
                              : null,
                          child: _currentUser!.avatar == null
                              ? Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Tap để thay đổi avatar'),
                      SizedBox(height: 32),

                      // Form cập nhật thông tin
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 24),

                      // Nút cập nhật
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isUpdating ? null : _updateProfile,
                          child: _isUpdating
                              ? CircularProgressIndicator()
                              : Text('Cập nhật thông tin'),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Nút đổi mật khẩu
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen(),
                              ),
                            );
                          },
                          child: Text('Đổi mật khẩu'),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Nút xem đơn hàng
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderHistoryScreen(),
                              ),
                            );
                          },
                          child: Text('Lịch sử đơn hàng'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

// ============================================
// CHANGE PASSWORD SCREEN
// ============================================

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RepositoryManager.auth.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đổi mật khẩu thành công!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Đổi mật khẩu thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đổi mật khẩu')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Đổi mật khẩu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// ORDER HISTORY SCREEN - Ví dụ sử dụng OrderRepository
// ============================================

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RepositoryManager.order.getUserOrders();

      if (response.success && response.data != null) {
        setState(() {
          _orders = response.data!;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải đơn hàng: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch sử đơn hàng')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text('Chưa có đơn hàng nào'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Đơn hàng #${order.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tổng tiền: ${order.totalAmount} VND'),
                            Text('Trạng thái: ${order.status}'),
                            Text('Ngày: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
                          ],
                        ),
                        trailing: order.status == 'pending'
                            ? TextButton(
                                onPressed: () => _cancelOrder(order.id),
                                child: Text('Hủy'),
                              )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(order.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Có'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await RepositoryManager.order.cancelOrder(orderId);
        
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã hủy đơn hàng')),
          );
          _loadOrders(); // Reload danh sách
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi hủy đơn hàng: $e')),
        );
      }
    }
  }
}

// ============================================
// ORDER DETAIL SCREEN
// ============================================

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  OrderDetailScreen(this.orderId);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await RepositoryManager.order.getOrderById(widget.orderId);

      if (response.success && response.data != null) {
        setState(() {
          _order = response.data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết đơn hàng')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(child: Text('Không tìm thấy đơn hàng'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng #${_order!.id}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      Text('Trạng thái: ${_order!.status}'),
                      Text('Ngày đặt: ${_order!.createdAt}'),
                      Text('Tổng tiền: ${_order!.totalAmount} VND'),
                      SizedBox(height: 24),
                      Text(
                        'Sản phẩm:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _order!.items.length,
                          itemBuilder: (context, index) {
                            final item = _order!.items[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text('Số lượng: ${item.quantity}'),
                              trailing: Text('${item.price} VND'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ============================================
// CÁCH SỬ DỤNG DEPENDENCIES TRONG PUBSPEC.YAML
// ============================================

/*
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                    # Cho HTTP requests
  shared_preferences: ^2.2.2     # Cho lưu trữ local (tokens)
  
dev_dependencies:
  flutter_test:
    sdk: flutter

# Optional dependencies cho chức năng bổ sung:
# image_picker: ^1.0.4           # Cho chọn hình ảnh
# connectivity_plus: ^5.0.1      # Kiểm tra kết nối mạng
# flutter_secure_storage: ^9.0.0 # Lưu trữ bảo mật hơn cho tokens
*/
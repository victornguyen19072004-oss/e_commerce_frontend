import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // Trạng thái lưu trữ danh sách sản phẩm động từ Backend
  List<dynamic> _newProducts = [];
  List<dynamic> _saleProducts = [];
  bool _isLoadingNew = true;
  bool _isLoadingSale = true;

  // Đường dẫn Base URL kết nối đến Backend đã deploy trên Render
  final String _baseUrl = "https://ecommerce-backend-8wur.onrender.com/api/products";

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  // Hàm tổng hợp để kích hoạt nạp dữ liệu từ cả 2 Tag
  Future<void> _loadAllProducts() async {
    await Future.wait([
      _fetchProductsByTag('NEW'),
      _fetchProductsByTag('SALE'),
    ]);
  }

  // Hàm gọi API lấy sản phẩm theo tên Tag cụ thể
  Future<void> _fetchProductsByTag(String tagName) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tag/$tagName'));
      if (response.statusCode == 200) {
        // Giải mã utf8 để tránh lỗi hiển thị font chữ tiếng Việt
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          if (tagName == 'NEW') {
            _newProducts = data;
            _isLoadingNew = false;
          } else {
            _saleProducts = data;
            _isLoadingSale = false;
          }
        });
      }
    } catch (e) {
      debugPrint("🚨 [API ERROR] Không thể lấy sản phẩm tag $tagName: $e");
      setState(() {
        if (tagName == 'NEW') _isLoadingNew = false;
        if (tagName == 'SALE') _isLoadingSale = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      // Bọc toàn bộ body trong RefreshIndicator để hỗ trợ tính năng kéo vuốt để làm mới dữ liệu
      body: RefreshIndicator(
        color: const Color(0xFFDB3022),
        onRefresh: () async {
          setState(() {
            _isLoadingNew = true;
            _isLoadingSale = true;
          });
          await _loadAllProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Đảm bảo luôn kéo vuốt được kể cả khi danh sách trống
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Phần Main Page: Big Banner
              _buildBanner(),
              const SizedBox(height: 32),

              // 2. Phần Section: NEW (Luôn ưu tiên xếp TRÊN phần SALE)
              _buildSectionHeader('New', 'You’ve never seen it before!'),
              const SizedBox(height: 16),
              _isLoadingNew
                  ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))))
                  : _buildProductList(products: _newProducts, isNew: true),
              const SizedBox(height: 32),

              // 3. Phần Section: SALE 
              _buildSectionHeader('Sale', 'Super summer sale'),
              const SizedBox(height: 16),
              _isLoadingSale
                  ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))))
                  : _buildProductList(products: _saleProducts, isNew: false),
              const SizedBox(height: 32),

              // 4. Phần Main 3: Cụm hình ảnh cuối trang từ Figma
              _buildMain3Grid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ===================== CÁC COMPONENT GIAO DIỆN =====================

  Widget _buildBanner() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/banner/big_banner.jpg',
          width: double.infinity,
          height: 500, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 500,
            color: Colors.grey[300],
            child: const Center(child: Text("Missing big_banner.jpg")),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/banner/fashion_title.png',
                width: 200,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "Fashion\nsale",
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0, 
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Text('View all', style: TextStyle(fontSize: 11, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildProductList({required List<dynamic> products, required bool isNew}) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Text(
          'Hiện chưa có sản phẩm nào trong mục này.',
          style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return SizedBox(
      height: 300, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, 
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          // Phân bổ xoay vòng thông minh từ sale_1.png đến sale_6.png dựa trên index % 6
          int imageNumber = (index % 6) + 1;
          String imagePath = 'assets/images/product/sale_$imageNumber.png';
          
          // Trích xuất an toàn giá trị số từ JSON Backend
          double salePrice = double.tryParse(product['salePrice'].toString()) ?? 0.0;
          double comparePrice = double.tryParse(product['comparePrice'].toString()) ?? 0.0;

          // Tính toán phần trăm giảm giá tự động dựa theo công thức thực tế của sản phẩm
          String discountPercentage = "-20%"; 
          if (comparePrice > salePrice && comparePrice > 0) {
            int calculatedPercent = (((comparePrice - salePrice) / comparePrice) * 100).round();
            discountPercentage = "-$calculatedPercent%";
          }

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none, 
                  children: [
                    // Khối ảnh sản phẩm bọc bo góc
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        imagePath,
                        height: 184,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 184, 
                          width: 150, 
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
                    ),
                    
                    // Nhãn Tag trạng thái sản phẩm
                    Positioned(
                      top: 8, left: 8,
                      child: isNew
                          ? Stack(
                              alignment: Alignment.center, 
                              children: [
                                Image.asset(
                                  'assets/images/button/new_tag.png',
                                  width: 40,
                                  errorBuilder: (context, error, stackTrace) => _buildFallbackTag('NEW', Colors.black),
                                ),
                                const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : _buildFallbackTag(discountPercentage, const Color(0xFFDB3022)), // Hiện % giảm giá động
                    ),

                    // Nút Favorite dạng Trái tim nổi lên trên biên ảnh
                    Positioned(
                      bottom: -18, 
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white, 
                          shape: BoxShape.circle, 
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                          ]
                        ),
                        child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), 
                
                // Điểm đánh giá (Tạm thời giữ xếp hạng 5 sao)
                Row(
                  children: List.generate(5, (starIndex) => const Icon(Icons.star, size: 14, color: Color(0xFFFFBA49))),
                ),
                const SizedBox(height: 4),
                // Hiển thị loại sản phẩm từ thuộc tính productType của BE (ví dụ: Simple / Variable)
                Text(
                  (product['productType'] ?? 'Simple').toString().toUpperCase(), 
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 4),
                // Tên sản phẩm thật lấy từ database
                Text(
                  product['productName'] ?? 'Unnamed Product', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Khối quản lý giá tiền động
                Row(
                  children: [
                    // Nếu là hàng SALE và có giá gốc cao hơn giá bán -> hiện giá gốc gạch ngang
                    if (!isNew && comparePrice > salePrice) 
                      Text(
                        '${comparePrice.round()}\$', 
                        style: const TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)
                      ),
                    if (!isNew && comparePrice > salePrice) const SizedBox(width: 6),
                    Text(
                      '${salePrice.round()}\$', 
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDB3022))
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMain3Grid() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 450, 
          decoration: const BoxDecoration(color: Colors.black),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/home_page/big_main.png', 
                width: double.infinity, 
                height: 450, 
                fit: BoxFit.cover,
                alignment: Alignment.topCenter, 
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey)
              ),
              const Positioned(
                bottom: 20, right: 20,
                child: Text('New collection', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    height: 150, width: double.infinity, color: Colors.white,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Text('Summer\nsale', style: TextStyle(color: Color(0xFFDB3022), fontSize: 34, fontWeight: FontWeight.bold, height: 1.1)),
                  ),
                  Container(
                    height: 150, width: double.infinity, color: Colors.black,
                    child: Stack(
                      children: [
                        Image.asset('assets/images/home_page/main_2.png', width: double.infinity, height: 150, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey)),
                        const Positioned(
                          bottom: 20, left: 16,
                          child: Text('Black', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 300, color: Colors.black,
                child: Image.asset('assets/images/home_page/main_3.png', width: double.infinity, height: 300, fit: BoxFit.cover,
                     errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFFDB3022), 
      unselectedItemColor: Colors.grey, 
      showSelectedLabels: true, 
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined), 
          activeIcon: Icon(Icons.home), 
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Bag',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

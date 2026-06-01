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
  List<dynamic> _newProducts = [];
  List<dynamic> _saleProducts = [];
  bool _isLoadingNew = true;
  bool _isLoadingSale = true;

  final String _baseUrl = "https://ecommerce-backend-8wur.onrender.com/api/products";

  final Map<String, String> _imageMap = {
    "Áo Thun Nam Mùa Hè": "assets/images/product/ao_thun.jpg",
    "Evening Dress Premium": "assets/images/product/evening_dress.jfif",
    "Giày Thể Thao Classic": "assets/images/product/giay_nike.jfif",
    "Kính Mát Thời Trang": "assets/images/product/kinh_mat.jpg",
    "Quần Jeans Ống Rộng": "assets/images/product/quan_jean.jpg",
    "Túi Xách Da Đeo Chéo": "assets/images/product/tui_xach.jfif",
  };

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    await Future.wait([
      _fetchProductsByTag('NEW'),
      _fetchProductsByTag('SALE'),
    ]);
  }

  Future<void> _fetchProductsByTag(String tagName) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tag/$tagName'));
      if (response.statusCode == 200) {
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
      debugPrint("Lỗi tải sản phẩm: $e");
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 24), // Thu hẹp từ 32 xuống 24
              _buildSectionHeader('New', 'You’ve never seen it before!'),
              const SizedBox(height: 16),
              _isLoadingNew
                  ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))))
                  : _buildProductList(products: _newProducts, isNew: true),
              const SizedBox(height: 0), // [SỬA ĐỔI 1]: Đẩy mục Sale lên gần mục New hơn (trước là 32)
              _buildSectionHeader('Sale', 'Super summer sale'),
              const SizedBox(height: 16),
              _isLoadingSale
                  ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))))
                  : _buildProductList(products: _saleProducts, isNew: false),
              const SizedBox(height: 32),
              _buildMain3Grid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Component nhãn bo góc [SỬA ĐỔI 2]
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12), // Bo góc cho nhãn
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildProductList({required List<dynamic> products, required bool isNew}) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          String productName = product['productName'] ?? '';
          String imagePath = _imageMap[productName] ?? 'assets/images/product/ao_thun.jpg';

          double salePrice = double.tryParse(product['salePrice'].toString()) ?? 0.0;
          double comparePrice = double.tryParse(product['comparePrice'].toString()) ?? 0.0;
          String discount = (comparePrice > salePrice) ? "-${(((comparePrice - salePrice) / comparePrice) * 100).round()}%" : "-20%";

          return Container(
            width: 150, margin: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(imagePath, height: 184, width: 150, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: isNew ? _buildTag("NEW", Colors.black) : _buildTag(discount, const Color(0xFFDB3022)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    if (!isNew && comparePrice > salePrice) Text('${comparePrice.round()}\$', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    Text(' ${salePrice.round()}\$', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDB3022))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Các Widget còn lại giữ nguyên để đảm bảo cấu trúc không đổi
  Widget _buildBanner() {
    return Stack(children: [
      Image.asset('assets/images/banner/big_banner.png', width: double.infinity, height: 500, fit: BoxFit.cover),
      Positioned(bottom: 30, left: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Image.asset('assets/images/banner/fashion_title.png', width: 200), const SizedBox(height: 16), SizedBox(width: 160, height: 36, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB3022), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))), child: const Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]))
    ]);
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey))]), const Text('View all', style: TextStyle(fontSize: 11, color: Colors.black))]));
  }

  Widget _buildMain3Grid() {
    return Column(children: [Container(height: 450, color: Colors.black, width: double.infinity, child: Image.asset('assets/images/home_page/big_main.png', fit: BoxFit.cover)), Row(children: [Expanded(child: Column(children: [Container(height: 150, color: Colors.white), Container(height: 150, color: Colors.black)])), Expanded(child: Container(height: 300, color: Colors.black))])]);
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(currentIndex: _currentIndex, onTap: (index) => setState(() => _currentIndex = index), selectedItemColor: const Color(0xFFDB3022), unselectedItemColor: Colors.grey, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'), BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Bag'), BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')]);
  }
}

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
    await Future.wait([_fetchProductsByTag('NEW'), _fetchProductsByTag('SALE')]);
  }

  Future<void> _fetchProductsByTag(String tagName) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/tag/$tagName'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          if (tagName == 'NEW') { _newProducts = data; _isLoadingNew = false; } 
          else { _saleProducts = data; _isLoadingSale = false; }
        });
      }
    } catch (e) {
      setState(() { _isLoadingNew = false; _isLoadingSale = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        color: const Color(0xFFDB3022),
        onRefresh: () async => await _loadAllProducts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 24),
              _buildSectionHeader('New', 'You’ve never seen it before!'),
              _isLoadingNew
                  ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFFDB3022))))
                  : _buildProductList(products: _newProducts, isNew: true),
              
              _buildSectionHeader('Sale', 'Super summer sale'),
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

  Widget _buildMain3Grid() {
    return Column(children: [
      _buildGridItem('assets/images/home_page/big_main.png', 'New collection', 400, isRight: true, isHeading: true),
      SizedBox(
        height: 300,
        child: Row(children: [
          Expanded(child: Column(children: [
            // Summer sale: hiển thị dọc
            Expanded(child: _buildGridItem('assets/images/home_page/summer_sale.png', 'Summer\nsale', 150, isRedTitle: true, isVerticalTitle: true)),
            Expanded(child: _buildGridItem('assets/images/home_page/main_2.png', 'Black', 150)),
          ])),
          // main_3: Bỏ title ("")
          Expanded(child: _buildGridItem('assets/images/home_page/main_3.png', "", 300)),
        ]),
      ),
    ]);
  }

  Widget _buildGridItem(String path, String title, double height, {bool isRight = false, bool isHeading = false, bool isRedTitle = false, bool isVerticalTitle = false}) {
    return Container(height: height, width: double.infinity, 
      decoration: BoxDecoration(color: Colors.white, image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover)),
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: isRight ? Alignment.bottomRight : (isVerticalTitle ? Alignment.centerLeft : Alignment.bottomLeft),
        child: Text(title, style: TextStyle(
          color: isRedTitle ? const Color(0xFFDB3022) : Colors.white, 
          fontSize: isHeading ? 34 : 24, 
          fontWeight: FontWeight.bold,
          height: 1.1
        )),
      ),
    );
  }

  Widget _buildProductList({required List<dynamic> products, required bool isNew}) {
    return SizedBox(height: 240, child: ListView.builder(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(left: 16.0, top: 16.0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        String name = product['productName'] ?? '';
        String path = _imageMap[name] ?? 'assets/images/product/ao_thun.jpg';
        double sale = double.tryParse(product['salePrice'].toString()) ?? 0.0;
        double compare = double.tryParse(product['comparePrice'].toString()) ?? 0.0;
        String discount = (compare > sale) ? "-${(((compare - sale) / compare) * 100).round()}%" : "-20%";

        return Container(width: 140, margin: const EdgeInsets.only(right: 16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(clipBehavior: Clip.none, children: [
            ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image.asset(path, height: 160, width: 140, fit: BoxFit.cover)),
            Positioned(top: 8, left: 8, child: isNew ? _buildTag("NEW", Colors.black) : _buildTag(discount, const Color(0xFFDB3022))),
          ]),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${sale.round()}\$', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDB3022))),
        ]));
      },
    ));
  }

  Widget _buildTag(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)));
  Widget _buildBanner() => Stack(children: [Image.asset('assets/images/banner/big_banner.png', width: double.infinity, height: 500, fit: BoxFit.cover)]);
  Widget _buildSectionHeader(String title, String subtitle) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey))]), const Text('View all')]));
  Widget _buildBottomNavigationBar() => BottomNavigationBar(currentIndex: _currentIndex, onTap: (idx) => setState(() => _currentIndex = idx), selectedItemColor: const Color(0xFFDB3022), unselectedItemColor: Colors.grey, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'), BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Bag'), BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'), BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')]);
}

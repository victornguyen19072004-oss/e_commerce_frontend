import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shop_page.dart';

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

  final String _baseUrl =
      "https://ecommerce-backend-8wur.onrender.com/api/products";

  final Map<String, String> _imageMap = {
    // --- CÁC SẢN PHẨM CŨ ---
    "Áo Thun Nam Mùa Hè": "assets/images/product/ao_thun.jpg",
    "Evening Dress Premium": "assets/images/product/evening_dress.jfif",
    "Giày Thể Thao Classic": "assets/images/product/giay_nike.jfif",
    "Kính Mát Thời Trang": "assets/images/product/kinh_mat.jpg",
    "Quần Jeans Ống Rộng": "assets/images/product/quan_jean.jpg",
    "Túi Xách Da Đeo Chéo": "assets/images/product/tui_xach.jfif",

    // --- CÁC SẢN PHẨM MỚI (50 MÓN) ---
    "Áo Sơ Mi Lụa Cổ V": "assets/images/categories/shirts_blouses/shirt_v.jfif",
    "Áo Blouse Công Sở Tay Bồng":
        "assets/images/categories/shirts_blouses/blouse_office.jfif",
    "Áo Sơ Mi Kẻ Sọc Form Rộng":
        "assets/images/categories/shirts_blouses/shirt_caro.jfif",
    "Áo Blouse Trễ Vai Họa Tiết":
        "assets/images/categories/shirts_blouses/blouse_pattern.jfif",
    "Áo Sơ Mi Trắng Basic":
        "assets/images/categories/shirts_blouses/shirt_classic.jfif",
    "Áo Cardigan Dáng Dài":
        "assets/images/categories/cardigans_sweaters/cardigan_long.jfif",
    "Áo Len Cổ Lọ Ấm Áp":
        "assets/images/categories/cardigans_sweaters/sweater_warm.jfif",
    "Áo Cardigan Len Thừng":
        "assets/images/categories/cardigans_sweaters/cardigan_len.jfif",
    "Áo Len Gân Cổ V":
        "assets/images/categories/cardigans_sweaters/sweater_v.jfif",
    "Áo Khoác Len Mỏng Mùa Thu":
        "assets/images/categories/cardigans_sweaters/sweater_fall.jfif",
    "Áo Dệt Kim Tay Ngắn": "assets/images/categories/knitwear/ao_det_kim.jfif",
    "Đầm Dệt Kim Ôm Body": "assets/images/categories/knitwear/dam_det_kim.jfif",
    "Áo Khoác Dệt Kim Cài Nút":
        "assets/images/categories/knitwear/ao_khoac_det_kim.jfif",
    "Chân Váy Len Dệt Kim":
        "assets/images/categories/knitwear/chan_vay_len.jfif",
    "Set Bộ Dệt Kim Thanh Lịch":
        "assets/images/categories/knitwear/set_bo_det_kim.jfif",
    "Áo Blazer Nữ Đen Classic":
        "assets/images/categories/blazers/ao_blazer.jfif",
    "Blazer Kẻ Caro Trẻ Trung":
        "assets/images/categories/blazers/blazer_caro.jfif",
    "Áo Blazer Pastel Dáng Suông":
        "assets/images/categories/blazers/blazer_pastel.jfif",
    "Blazer Ngắn Tay Mùa Hè":
        "assets/images/categories/blazers/blazer_fall.jfif",
    "Áo Khoác Blazer Kaki": "assets/images/categories/blazers/blazer_kaki.jfif",
    "Áo Khoác Dạ Dáng Dài":
        "assets/images/categories/outerwear/outerwear_long.jfif",
    "Áo Phao Dáng Ngắn": "assets/images/categories/outerwear/phao_ngan.jfif",
    "Áo Khoác Da Biker": "assets/images/categories/outerwear/khoac_biker.jfif",
    "Áo Khoác Bomber Năng Động":
        "assets/images/categories/outerwear/khoac_bomber.jfif",
    "Áo Măng Tô Kaki": "assets/images/categories/outerwear/mang_to_kaki.jfif",
    "Quần Tây Công Sở Dáng Đứng":
        "assets/images/categories/pants/pant_office.jfif",
    "Quần Ống Suông Vải Mềm":
        "assets/images/categories/pants/pant_ong_suong.jfif",
    "Quần Kaki Nữ Năng Động": "assets/images/categories/pants/pant_kaki.jfif",
    "Quần Baggy Lưng Cao": "assets/images/categories/pants/pant_baggy.jfif",
    "Quần Thể Thao Jogger": "assets/images/categories/pants/pant_jogger.jfif",
    "Quần Jeans Skinny Xanh Đậm":
        "assets/images/categories/jeans/jean_skinny.jfif",
    "Quần Jeans Ống Loe Retro":
        "assets/images/categories/jeans/jean_retro.jfif",
    "Quần Jeans Rách Phá Cách": "assets/images/categories/jeans/jean_rach.jfif",
    "Quần Mom Jeans Lưng Cao": "assets/images/categories/jeans/jean_mom.jfif",
    "Quần Shorts Jeans Gấu Tua Rua":
        "assets/images/categories/jeans/jean_short.jfif",
    "Quần Short Kaki Cơ Bản": "assets/images/categories/shorts/short_kaki.jfif",
    "Quần Short Vải Linen Mùa Hè":
        "assets/images/categories/shorts/short_linen.jfif",
    "Quần Short Thể Thao Cotton":
        "assets/images/categories/shorts/short_cotton.jfif",
    "Quần Giả Váy Xếp Ly": "assets/images/categories/shorts/short_vay.jfif",
    "Quần Short Da Thời Trang": "assets/images/categories/shorts/short_da.jfif",
    "Chân Váy Chữ A Công Sở": "assets/images/categories/skirts/skirt_A.jfif",
    "Chân Váy Midi Xếp Ly": "assets/images/categories/skirts/skirt_midi.jfif",
    "Chân Váy Hoa Nhí Dáng Dài":
        "assets/images/categories/skirts/skirt_flower.jfif",
    "Chân Váy Jean Ngắn": "assets/images/categories/skirts/skirt_jean.jfif",
    "Chân Váy Bút Chì Ôm Dáng":
        "assets/images/categories/skirts/skirt_pencil.jfif",
    "Đầm Maxi Trễ Vai Đi Biển":
        "assets/images/categories/dresses/dress_maxi.jfif",
    "Váy Xòe Họa Tiết Hoa Nhí":
        "assets/images/categories/dresses/dress_flowerl.jfif",
    "Đầm Body Cổ V Gợi Cảm": "assets/images/categories/dresses/dress_body.jfif",
    "Váy Sơ Mi Thắt Eo": "assets/images/categories/dresses/dress_shirt.jfif",
    "Đầm Dự Tiệc Dáng Dài Xẻ Tà":
        "assets/images/categories/dresses/dress_wedding.jfif",
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
              const SizedBox(height: 24),
              _buildSectionHeader('New', 'You’ve never seen it before!'),
              const SizedBox(height: 16),
              _isLoadingNew
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFDB3022),
                        ),
                      ),
                    )
                  : _buildProductList(products: _newProducts, isNew: true),
              const SizedBox(height: 16),
              _buildSectionHeader('Sale', 'Super summer sale'),
              const SizedBox(height: 16),
              _isLoadingSale
                  ? const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFDB3022),
                        ),
                      ),
                    )
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildProductList({
    required List<dynamic> products,
    required bool isNew,
  }) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          String productName = product['productName'] ?? '';
          String imagePath =
              _imageMap[productName] ?? 'assets/images/product/ao_thun.jpg';
          double salePrice =
              double.tryParse(product['salePrice'].toString()) ?? 0.0;
          double comparePrice =
              double.tryParse(product['comparePrice'].toString()) ?? 0.0;
          String discount = (comparePrice > salePrice && comparePrice > 0)
              ? "-${(((comparePrice - salePrice) / comparePrice) * 100).round()}%"
              : "-20%";

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        imagePath,
                        height: 160,
                        width: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          width: 140,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: isNew
                          ? _buildTag("NEW", Colors.black)
                          : _buildTag(discount, const Color(0xFFDB3022)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (!isNew && comparePrice > salePrice)
                      Text(
                        '${comparePrice.round()}\$',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    if (!isNew && comparePrice > salePrice)
                      const SizedBox(width: 4),
                    Text(
                      '${salePrice.round()}\$',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDB3022),
                      ),
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

  Widget _buildBanner() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/banner/big_banner.png',
          width: double.infinity,
          height: 500,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 30,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset('assets/images/banner/fashion_title.png', width: 200),
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const Text(
            'View all',
            style: TextStyle(fontSize: 11, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // KHÔI PHỤC LẠI GIAO DIỆN CHUẨN FIGMA
  Widget _buildMain3Grid() {
    return Column(
      children: [
        _buildGridItem(
          'assets/images/home_page/big_main.png',
          'New collection',
          400,
          isRight: true,
          isHeading: true,
        ),
        SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        'assets/images/home_page/summer_sale.png',
                        'Summer\nsale',
                        150,
                        isRedTitle: true,
                        isVerticalTitle: true,
                      ),
                    ),
                    Expanded(
                      child: _buildGridItem(
                        'assets/images/home_page/main_2.png',
                        'Black',
                        150,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildGridItem(
                  'assets/images/home_page/main_3.png',
                  "",
                  300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String path,
    String title,
    double height, {
    bool isRight = false,
    bool isHeading = false,
    bool isRedTitle = false,
    bool isVerticalTitle = false,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: isRight
            ? Alignment.bottomRight
            : (isVerticalTitle ? Alignment.centerLeft : Alignment.bottomLeft),
        child: Text(
          title,
          style: TextStyle(
            color: isRedTitle ? const Color(0xFFDB3022) : Colors.white,
            fontSize: isHeading ? 34 : 24,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  // KHÔI PHỤC LOGIC CHUYỂN TAB
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_currentIndex == index) return;
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const ShopPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      selectedItemColor: const Color(0xFFDB3022),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
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

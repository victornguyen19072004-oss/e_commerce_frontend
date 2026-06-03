import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
class CatalogPage extends StatefulWidget {
  final String categoryName;
  const CatalogPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  int _currentIndex = 1;
  bool _isGridView = false; // Trạng thái chuyển đổi: false (Dọc), true (Lưới)
  bool _isLoading = true;
  List<dynamic> _products = [];

  final String _baseUrl = "https://ecommerce-backend-8wur.onrender.com/api/products";

  // Ánh xạ cực kỳ chi tiết 50 sản phẩm bạn đã chuẩn bị
  final Map<String, String> _imageMap = {
    // Shirts & Blouses
    "Áo Sơ Mi Lụa Cổ V": "assets/images/categories/shirts_blouses/shirt_v.jfif",
    "Áo Blouse Công Sở Tay Bồng": "assets/images/categories/shirts_blouses/blouse_office.jfif",
    "Áo Sơ Mi Kẻ Sọc Form Rộng": "assets/images/categories/shirts_blouses/shirt_caro.jfif",
    "Áo Blouse Trễ Vai Họa Tiết": "assets/images/categories/shirts_blouses/blouse_pattern.jfif",
    "Áo Sơ Mi Trắng Basic": "assets/images/categories/shirts_blouses/shirt_classic.jfif",
    // Cardigans & Sweaters
    "Áo Cardigan Dáng Dài": "assets/images/categories/cardigans_sweaters/cardigan_long.jfif",
    "Áo Len Cổ Lọ Ấm Áp": "assets/images/categories/cardigans_sweaters/sweater_warm.jfif",
    "Áo Cardigan Len Thừng": "assets/images/categories/cardigans_sweaters/cardigan_len.jfif",
    "Áo Len Gân Cổ V": "assets/images/categories/cardigans_sweaters/sweater_v.jfif",
    "Áo Khoác Len Mỏng Mùa Thu": "assets/images/categories/cardigans_sweaters/sweater_fall.jfif",
    // Knitwear
    "Áo Dệt Kim Tay Ngắn": "assets/images/categories/knitwear/ao_det_kim.jfif",
    "Đầm Dệt Kim Ôm Body": "assets/images/categories/knitwear/dam_det_kim.jfif",
    "Áo Khoác Dệt Kim Cài Nút": "assets/images/categories/knitwear/ao_khoac_det_kim.jfif",
    "Chân Váy Len Dệt Kim": "assets/images/categories/knitwear/chan_vay_len.jfif",
    "Set Bộ Dệt Kim Thanh Lịch": "assets/images/categories/knitwear/set_bo_det_kim.jfif",
    // Blazers
    "Áo Blazer Nữ Đen Classic": "assets/images/categories/blazers/ao_blazer.jfif",
    "Blazer Kẻ Caro Trẻ Trung": "assets/images/categories/blazers/blazer_caro.jfif",
    "Áo Blazer Pastel Dáng Suông": "assets/images/categories/blazers/blazer_pastel.jfif",
    "Blazer Ngắn Tay Mùa Hè": "assets/images/categories/blazers/blazer_fall.jfif",
    "Áo Khoác Blazer Kaki": "assets/images/categories/blazers/blazer_kaki.jfif",
    // Outerwear
    "Áo Khoác Dạ Dáng Dài": "assets/images/categories/outerwear/outerwear_long.jfif",
    "Áo Phao Dáng Ngắn": "assets/images/categories/outerwear/phao_ngan.jfif",
    "Áo Khoác Da Biker": "assets/images/categories/outerwear/khoac_biker.jfif",
    "Áo Khoác Bomber Năng Động": "assets/images/categories/outerwear/khoac_bomber.jfif",
    "Áo Măng Tô Kaki": "assets/images/categories/outerwear/mang_to_kaki.jfif",
    // Pants
    "Quần Tây Công Sở Dáng Đứng": "assets/images/categories/pants/pant_office.jfif",
    "Quần Ống Suông Vải Mềm": "assets/images/categories/pants/pant_ong_suong.jfif",
    "Quần Kaki Nữ Năng Động": "assets/images/categories/pants/pant_kaki.jfif",
    "Quần Baggy Lưng Cao": "assets/images/categories/pants/pant_baggy.jfif",
    "Quần Thể Thao Jogger": "assets/images/categories/pants/pant_jogger.jfif",
    // Jeans
    "Quần Jeans Skinny Xanh Đậm": "assets/images/categories/jeans/jean_skinny.jfif",
    "Quần Jeans Ống Loe Retro": "assets/images/categories/jeans/jean_retro.jfif",
    "Quần Jeans Rách Phá Cách": "assets/images/categories/jeans/jean_rach.jfif",
    "Quần Mom Jeans Lưng Cao": "assets/images/categories/jeans/jean_mom.jfif",
    "Quần Shorts Jeans Gấu Tua Rua": "assets/images/categories/jeans/jean_short.jfif",
    // Shorts
    "Quần Short Kaki Cơ Bản": "assets/images/categories/shorts/short_kaki.jfif",
    "Quần Short Vải Linen Mùa Hè": "assets/images/categories/shorts/short_linen.jfif",
    "Quần Short Thể Thao Cotton": "assets/images/categories/shorts/short_cotton.jfif",
    "Quần Giả Váy Xếp Ly": "assets/images/categories/shorts/short_vay.jfif",
    "Quần Short Da Thời Trang": "assets/images/categories/shorts/short_da.jfif",
    // Skirts
    "Chân Váy Chữ A Công Sở": "assets/images/categories/skirts/skirt_A.jfif",
    "Chân Váy Midi Xếp Ly": "assets/images/categories/skirts/skirt_midi.jfif",
    "Chân Váy Hoa Nhí Dáng Dài": "assets/images/categories/skirts/skirt_flower.jfif",
    "Chân Váy Jean Ngắn": "assets/images/categories/skirts/skirt_jean.jfif",
    "Chân Váy Bút Chì Ôm Dáng": "assets/images/categories/skirts/skirt_pencil.jfif",
    // Dresses
    "Đầm Maxi Trễ Vai Đi Biển": "assets/images/categories/dresses/dress_maxi.jfif",
    "Váy Xòe Họa Tiết Hoa Nhí": "assets/images/categories/dresses/dress_flowerl.jfif",
    "Đầm Body Cổ V Gợi Cảm": "assets/images/categories/dresses/dress_body.jfif",
    "Váy Sơ Mi Thắt Eo": "assets/images/categories/dresses/dress_shirt.jfif",
    "Đầm Dự Tiệc Dáng Dài Xẻ Tà": "assets/images/categories/dresses/dress_wedding.jfif",
  };

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      // Encode URL để xử lý khoảng trắng (vd: Shirts & Blouses)
      final String url = "$_baseUrl/category/${Uri.encodeComponent(widget.categoryName)}";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _products = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Lỗi tải sản phẩm danh mục: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header chức năng (Tags ngang & Filters)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                // Tags tĩnh giả lập (T-shirts, Crop tops, Blouses...)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip("T-shirts"),
                      _buildFilterChip("Crop tops"),
                      _buildFilterChip("Blouses"),
                      _buildFilterChip("Sleeveless"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hàng Filter / Giá / Đổi chế độ View
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.filter_list, size: 24),
                          SizedBox(width: 8),
                          Text("Filters", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(Icons.swap_vert, size: 24),
                          SizedBox(width: 8),
                          Text("Price: lowest to high", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      IconButton(
                        // Chuyển đổi Icon dựa trên trạng thái (Mặc định hiển thị view_mode, bấm vào hiển thị view_list)
                        icon: Image.asset(
                          _isGridView 
                              ? 'assets/images/cate_display/view_list.png' 
                              : 'assets/images/cate_display/view_mode.png',
                          width: 24,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isGridView = !_isGridView; // Đổi trạng thái
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Danh sách sản phẩm (Dọc hoặc Lưới)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022)))
                : _products.isEmpty
                    ? const Center(child: Text("Chưa có sản phẩm nào trong danh mục này."))
                    : _isGridView
                        ? _buildGridView()
                        : _buildListView(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Component Filter Chip tĩnh
  Widget _buildFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  // Component nhãn bo góc (-20%, NEW)
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  // Nút Favorite Heart nổi
  Widget _buildFavoriteButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: const Icon(Icons.favorite_border, size: 20, color: Colors.grey),
    );
  }

  // 1. Chế độ hiển thị LIST VIEW (Dọc - Catalog 1)
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        String name = product['productName'] ?? '';
        String path = _imageMap[name] ?? 'assets/images/product/ao_thun.jpg'; // Ảnh mặc định nếu thiếu
        double sale = double.tryParse(product['salePrice'].toString()) ?? 0.0;
        double compare = double.tryParse(product['comparePrice'].toString()) ?? 0.0;
        String discount = (compare > sale && compare > 0) ? "-${(((compare - sale) / compare) * 100).round()}%" : "-20%";
        
        // Kiểm tra xem sản phẩm có nằm trong danh sách tags chứa NEW không
        bool isNew = false;
        if (product['tags'] != null) {
          for(var t in product['tags']) {
            if(t['tagName'] == 'NEW') isNew = true;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                    child: Image.asset(path, width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(width:120, color: Colors.grey[300])),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          const Text("Mango", style: TextStyle(color: Colors.grey, fontSize: 11)), // Brand tĩnh
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (_) => const Icon(Icons.star, size: 14, color: Color(0xFFFFBA49))),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (compare > sale) Text('${compare.round()}\$', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 14)),
                              if (compare > sale) const SizedBox(width: 4),
                              Text('${sale.round()}\$', style: const TextStyle(color: Color(0xFFDB3022), fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Nhãn
              Positioned(top: 8, left: 8, child: isNew ? _buildTag("NEW", Colors.black) : _buildTag(discount, const Color(0xFFDB3022))),
              // Nút tim
              Positioned(bottom: -15, right: 0, child: _buildFavoriteButton()),
            ],
          ),
        );
      },
    );
  }

  // 2. Chế độ hiển thị GRID VIEW (Lưới - Catalog 2)
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55, // Điều chỉnh để có không gian cho ảnh và chữ
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        String name = product['productName'] ?? '';
        String path = _imageMap[name] ?? 'assets/images/product/ao_thun.jpg';
        double sale = double.tryParse(product['salePrice'].toString()) ?? 0.0;
        double compare = double.tryParse(product['comparePrice'].toString()) ?? 0.0;
        String discount = (compare > sale && compare > 0) ? "-${(((compare - sale) / compare) * 100).round()}%" : "-20%";

        bool isNew = false;
        if (product['tags'] != null) {
          for(var t in product['tags']) {
            if(t['tagName'] == 'NEW') isNew = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(path, width: double.infinity, height: 184, fit: BoxFit.cover, errorBuilder: (_,__,___)=>Container(height: 184, color: Colors.grey[300])),
                ),
                Positioned(top: 8, left: 8, child: isNew ? _buildTag("NEW", Colors.black) : _buildTag(discount, const Color(0xFFDB3022))),
                Positioned(bottom: -15, right: 0, child: _buildFavoriteButton()),
              ],
            ),
            const SizedBox(height: 24),
            Row(children: List.generate(5, (_) => const Icon(Icons.star, size: 14, color: Color(0xFFFFBA49)))),
            const SizedBox(height: 4),
            const Text("Mango", style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                if (compare > sale) Text('${compare.round()}\$', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 14)),
                if (compare > sale) const SizedBox(width: 4),
                Text('${sale.round()}\$', style: const TextStyle(color: Color(0xFFDB3022), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex, // Mặc định ở Shop là 1
      onTap: (index) {
        if (_currentIndex == index) return;

        if (index == 0) {
          // Bấm vào tab Home -> Quay về HomePage
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
        // Thêm chuyển trang cho Bag, Favorite, Profile ở đây sau này
        else {
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

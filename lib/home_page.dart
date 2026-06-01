import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Trạng thái của Bottom Navigation Bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      // Bọc toàn bộ nội dung trong SingleChildScrollView để vuốt từ trên xuống dưới
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần Main Page: Big Banner
            _buildBanner(),
            const SizedBox(height: 32),

            // 2. Phần Section: NEW (Được yêu cầu đặt TREN Sale)
            _buildSectionHeader('New', 'You’ve never seen it before!'),
            const SizedBox(height: 16),
            _buildProductList(isNew: true),
            const SizedBox(height: 32),

            // 3. Phần Section: SALE (Phần Main 2)
            _buildSectionHeader('Sale', 'Super summer sale'),
            const SizedBox(height: 16),
            _buildProductList(isNew: false),
            const SizedBox(height: 32),

            // 4. Phần Main 3: Cụm hình ảnh cuối trang
            _buildMain3Grid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ===================== CÁC COMPONENT GIAO DIỆN =====================

  Widget _buildBanner() {
    return Stack(
      children: [
        // Ảnh nền Banner
        Image.asset(
          'assets/images/banner/big_banner.jpg',
          width: double.infinity,
          height: 500, // Chiều cao mô phỏng theo Figma
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 500,
            color: Colors.grey[300],
            child: const Center(child: Text("Missing big_banner.jpg")),
          ),
        ),
        // Chữ Fashion Sale và Nút Check đè lên trên
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
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/banner/check_button.png',
                    width: 160,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 160, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFDB3022), borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                  const Text('Check', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              )
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
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const Text('View all', style: TextStyle(fontSize: 11, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildProductList({required bool isNew}) {
    // Tạm thời hiển thị 3 sản phẩm tĩnh
    return SizedBox(
      height: 280, // Giới hạn chiều cao cho danh sách trượt ngang
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: 3,
        itemBuilder: (context, index) {
          // Lấy hình ảnh từ sale_1.png đến sale_3.png
          String imagePath = 'assets/images/product/sale_${index + 1}.png';
          
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        imagePath,
                        height: 184,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 184, width: 150, color: Colors.grey[300]),
                      ),
                    ),
                    // Tag New hoặc Sale
                    Positioned(
                      top: 8, left: 8,
                      child: isNew
                          ? Image.asset(
                              'assets/images/button/new_tag.png',
                              width: 40,
                              errorBuilder: (context, error, stackTrace) => _buildFallbackTag('NEW', Colors.black),
                            )
                          : _buildFallbackTag('-20%', const Color(0xFFDB3022)), // Tag màu đỏ cho hàng Sale
                    ),
                    // Nút Favorite trái tim góc dưới phải ảnh
                    Positioned(
                      bottom: -16, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Thông tin sản phẩm tĩnh (đợi đổ BE vào)
                Row(
                  children: List.generate(5, (starIndex) => const Icon(Icons.star, size: 14, color: Color(0xFFFFBA49))),
                ),
                const SizedBox(height: 4),
                const Text('Dorothy Perkins', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                const Text('Evening Dress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!isNew) const Text('15\$', style: TextStyle(fontSize: 14, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                    if (!isNew) const SizedBox(width: 4),
                    const Text('12\$', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDB3022))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Tag chữa cháy trong trường hợp ảnh tag bị lỗi
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
        // Khối 1: New Collection
        Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(color: Colors.black),
          child: Stack(
            children: [
              Image.asset('assets/images/home_page/big_main.png', width: double.infinity, height: 200, fit: BoxFit.cover,
                 errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey)),
              const Positioned(
                bottom: 20, right: 20,
                child: Text('New collection', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        // Khối 2: Lưới phía dưới
        Row(
          children: [
            // Cột trái
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    height: 150, width: double.infinity, color: Colors.white,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Text('Summer\nsale', style: TextStyle(color: Color(0xFFDB3022), fontSize: 34, fontWeight: FontWeight.bold)),
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
            // Cột phải
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
    // Tạm dùng Icon mặc định của Flutter nếu bạn chưa cung cấp đủ ảnh tab1->tab5
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFDB3022),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 10),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Bag'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
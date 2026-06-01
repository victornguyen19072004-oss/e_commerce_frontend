import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Phần Main Page: Big Banner
            _buildBanner(),
            const SizedBox(height: 32),

            // 2. Phần Section: NEW
            _buildSectionHeader('New', 'You’ve never seen it before!'),
            const SizedBox(height: 16),
            _buildProductList(isNew: true),
            const SizedBox(height: 32),

            // 3. Phần Section: SALE
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
          'assets/images/banner/big_banner.png',
          width: double.infinity,
          height: 500, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 500,
            color: Colors.grey[300],
            child: const Center(child: Text("Missing big_banner.png")),
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
              
              // [SỬA ĐỔI 3]: Thay thế ảnh tĩnh bằng nút bấm thực sự của Flutter để chữ Check căn giữa 100%
              SizedBox(
                width: 160,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý sự kiện khi bấm nút Check
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022), // Màu đỏ chủ đạo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Bo tròn 2 đầu
                    ),
                    elevation: 0, // Xóa bóng mờ để giống thiết kế phẳng
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  Widget _buildProductList({required bool isNew}) {
    return SizedBox(
      height: 300, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none, 
        padding: const EdgeInsets.only(left: 16.0),
        itemCount: 3,
        itemBuilder: (context, index) {
          String imagePath = 'assets/images/product/sale_${index + 1}.png';
          
          return Container(
            width: 150,
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
                        height: 184,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 184, width: 150, color: Colors.grey[300]),
                      ),
                    ),
                    
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
                          : _buildFallbackTag('-20%', const Color(0xFFDB3022)),
                    ),

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
          height: 450, // [SỬA ĐỔI 4]: Tăng chiều cao lên 450
          decoration: const BoxDecoration(color: Colors.black),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/home_page/big_main.png', 
                width: double.infinity, 
                height: 450, 
                fit: BoxFit.cover,
                alignment: Alignment.topCenter, // Ưu tiên giữ lại phần đỉnh (tóc/mặt) của ảnh
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey)
              ),
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
      showSelectedLabels: false, // [SỬA ĐỔI 1]: Tắt Label để chữ không bị đè lên ảnh
      showUnselectedLabels: false,
      items: [
        // [SỬA ĐỔI 2]: Nếu tab được chọn thì dùng ảnh không có bộ lọc (màu gốc). Nếu không chọn thì chuyển xám.
        BottomNavigationBarItem(
          icon: _buildNavIcon('assets/images/nav_bar/tab1_home.png', 0), 
          label: ''
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon('assets/images/nav_bar/tab2_shop.png', 1), 
          label: ''
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon('assets/images/nav_bar/tab3_bag.png', 2), 
          label: ''
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon('assets/images/nav_bar/tab4_favorite.png', 3), 
          label: ''
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon('assets/images/nav_bar/tab5_my_profile.png', 4), 
          label: ''
        ),
      ],
    );
  }

  // Hàm hỗ trợ render Icon Navigation Bar
  Widget _buildNavIcon(String path, int index) {
    return Image.asset(
      path,
      width: 44, // Tăng kích thước chiều rộng ảnh để chữ trong ảnh dễ đọc hơn
      // Nếu tab này đang được chọn thì color = null (giữ màu gốc của ảnh). Nếu không thì phủ lớp xám.
      color: _currentIndex == index ? null : Colors.grey,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}

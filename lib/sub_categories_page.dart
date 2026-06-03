import 'package:flutter/material.dart';
import 'catalog_page.dart';
import 'home_page.dart';
class SubCategoriesPage extends StatefulWidget {
  const SubCategoriesPage({Key? key}) : super(key: key);

  @override
  State<SubCategoriesPage> createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  int _currentIndex = 1;

  final List<String> _categories = const [
    "Tops",
    "Shirts & Blouses",
    "Cardigans & Sweaters",
    "Knitwear",
    "Blazers",
    "Outerwear",
    "Pants",
    "Jeans",
    "Shorts",
    "Skirts",
    "Dresses"
  ];

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
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
          const SizedBox(height: 16),
          // Nút VIEW ALL ITEMS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogPage(categoryName: "Tops")));
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/shop_nav_bar/view_all.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "VIEW ALL ITEMS",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tiêu đề
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Choose category",
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 8),
          
          // Danh sách 11 danh mục
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  title: Text(
                    _categories[index],
                    style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w400),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CatalogPage(categoryName: _categories[index])),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

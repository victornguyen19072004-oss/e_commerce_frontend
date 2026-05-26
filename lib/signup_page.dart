import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Nút Back
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () {
                  // Xử lý sự kiện quay lại
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                splashRadius: 24,
              ),
              const SizedBox(height: 32),

              // Tiêu đề
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold, // Đã in đậm tiêu đề
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 72),

              // Form Nhập liệu
              _buildTextField(
                label: 'Name',
                initialValue: 'Mr. Muffin',
                suffixIcon: Image.asset(
                  'assets/images/icon/green-tick.png',
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(height: 8),

              _buildTextField(label: 'Email', initialValue: 'mrmuffi'),
              const SizedBox(height: 8),

              _buildTextField(label: 'Password', isPassword: true),
              const SizedBox(height: 16),

              // Nút chuyển sang Đăng nhập
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold, // Chỉnh in đậm theo yêu cầu
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Icon(
                      Icons.arrow_right_alt,
                      color: Color(0xFFDB3022), // Màu đỏ theo thiết kế
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Nút SIGN UP
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    elevation: 4,
                    shadowColor: const Color(0xFFDB3022).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Phần Social Login
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Or sign up with social account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold, // Chỉnh in đậm theo yêu cầu
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          'assets/images/button/google-icon.png',
                        ),
                        const SizedBox(width: 16),
                        // Bật cờ isRounded = true để bo góc icon Facebook
                        _buildSocialButton(
                          'assets/images/button/facebook-icon.png',
                          isRounded: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget dùng chung để tạo ô nhập liệu trắng có bóng đổ
  Widget _buildTextField({
    required String label,
    String? initialValue,
    Widget? suffixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: isPassword,
        // Font chữ của Mr. Muffin, mrmuffi được in đậm tại đây
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          // Đảm bảo phần nhãn (Label) vẫn bình thường, không in đậm
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always, // Ép nhãn luôn trôi lên trên như thiết kế
          suffixIcon: suffixIcon != null
              ? Padding(padding: const EdgeInsets.all(16.0), child: suffixIcon)
              : null,
        ),
      ),
    );
  }

  // Widget dùng chung để tạo ô Social Button (đã thêm logic bo góc)
  Widget _buildSocialButton(String assetPath, {bool isRounded = false}) {
    return Container(
      width: 92,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: isRounded
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4.0), // Bo tròn nhẹ 4 góc
                child: Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }
}
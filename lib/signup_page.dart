import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController(text: 'Mr. Muffin');
  final TextEditingController _emailController = TextEditingController(text: 'mrmuffi@gmail.com');
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: kIsWeb
        ? '790202574296-9qsllsor2jv2n4qmg7d38fi1p3p6netv.apps.googleusercontent.com' // Web Client ID
        : '790202574296-7fi2obusn34e5us92tpjhvif6bgfd3ea.apps.googleusercontent.com', // iOS Client ID
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ====================== ĐĂNG KÝ BÌNH THƯỜNG ======================
  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Vui lòng nhập họ tên");
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Vui lòng nhập email");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập mật khẩu");
      return;
    }

    try {
      final result = await _apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      String token = result['accessToken'];
      await _storage.write(key: 'auth_token', value: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công!")),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar("Lỗi: ${e.toString()}");
    }
  }

  // ====================== ĐĂNG KÝ BẰNG GOOGLE ======================
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // Người dùng hủy

      final result = await _apiService.oauthLogin(
        "google",
        googleUser.email,
        googleUser.displayName ?? "Google User",
        googleUser.id,
      );

      String token = result['accessToken'];
      await _storage.write(key: 'auth_token', value: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký bằng Google thành công!")),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar("Google Sign-In thất bại: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 32),

              // Tiêu đề
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 72),

              // Form Nhập liệu
              _buildTextField(
                label: 'Name',
                controller: _nameController,
                suffixIcon: Image.asset('assets/images/icon/green-tick.png', width: 20, height: 20),
              ),
              const SizedBox(height: 8),

              _buildTextField(label: 'Email', controller: _emailController),
              const SizedBox(height: 8),

              _buildTextField(label: 'Password', controller: _passwordController, isPassword: true),
              const SizedBox(height: 16),

              // Nút chuyển sang Đăng nhập
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Icon(Icons.arrow_right_alt, color: Color(0xFFDB3022), size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Nút SIGN UP
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    elevation: 4,
                    shadowColor: const Color(0xFFDB3022).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
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
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _handleGoogleSignIn,
                          child: _buildSocialButton('assets/images/button/google-icon.png'),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _showSnackBar("Tính năng Facebook đang phát triển..."),
                          child: _buildSocialButton('assets/images/button/facebook-icon.png', isRounded: true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget dùng chung để tạo ô nhập liệu
  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    Widget? suffixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 1), blurRadius: 8),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: suffixIcon != null
              ? Padding(padding: const EdgeInsets.all(16.0), child: suffixIcon)
              : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, {bool isRounded = false}) {
    return Container(
      width: 92,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 1), blurRadius: 8),
        ],
      ),
      child: Center(
        child: isRounded
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.cover),
              )
            : Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController _emailController = TextEditingController(text: 'muffin.sweet@gmail.com');
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: kIsWeb
        ? '790202574296-9qsllsor2jv2n4qmg7d38fi1p3p6netv.apps.googleusercontent.com' // Web Client ID
        : '790202574296-7fi2obusn34e5us92tpjhvif6bgfd3ea.apps.googleusercontent.com', // iOS Client ID
  );

  bool _isEmailValid = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kiểm tra email
  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() => _isEmailValid = false);
      return;
    }
    final bool isValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);

    setState(() => _isEmailValid = isValid);
  }

  // ====================== ĐĂNG NHẬP BÌNH THƯỜNG ======================
  Future<void> _handleLogin() async {
    if (!_isEmailValid || _emailController.text.trim().isEmpty) {
      _showSnackBar("Email không hợp lệ");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập mật khẩu");
      return;
    }

    try {
      final result = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      String token = result['accessToken'];
      await _storage.write(key: 'auth_token', value: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng nhập thành công!")),
        );
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Lỗi: ${e.toString()}");
      }
    }
  }

  // ====================== ĐĂNG NHẬP BẰNG GOOGLE ======================
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

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
          const SnackBar(content: Text("Đăng nhập bằng Google thành công!")),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Google Sign-In thất bại: $e");
      }
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
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 32),

              const Text(
                'Login',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 72),

              // Email Field
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                onChanged: _validateEmail,
                isError: !_isEmailValid,
                errorText: 'Not a valid email address. Should be your@email.com',
                suffixIcon: _isEmailValid
                    ? Image.asset('assets/images/icon/green-tick.png', width: 20, height: 20)
                    : Image.asset('assets/images/icon/red-tick.png', width: 20, height: 20),
              ),
              const SizedBox(height: 8),

              // Password Field
              _buildTextField(
                label: 'Password',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              // Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('Forgot your password? ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/forgot'),
                    child: const Icon(Icons.arrow_right_alt, color: Color(0xFFDB3022), size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Nút LOGIN
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    elevation: 4,
                    shadowColor: const Color(0xFFDB3022).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 140),

              // Social Login
              Center(
                child: Column(
                  children: [
                    const Text('Or login with social account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                          onTap: () => _showSnackBar("Facebook đang phát triển..."),
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

  // Widget TextField
  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    Widget? suffixIcon,
    bool isPassword = false,
    bool isError = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: isError ? Border.all(color: Colors.red, width: 1.0) : null,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 1), blurRadius: 8),
            ],
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            obscureText: isPassword,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: isError ? Colors.red : Colors.grey, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: suffixIcon != null
                  ? Padding(padding: const EdgeInsets.all(16.0), child: suffixIcon)
                  : null,
            ),
          ),
        ),
        if (isError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 16.0),
            child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath, {bool isRounded = false}) {
    return Container(
      width: 92,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Center(
        child: isRounded
            ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.asset(assetPath, width: 24, height: 24))
            : Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }
}
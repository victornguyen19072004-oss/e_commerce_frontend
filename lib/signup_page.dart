import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/auth_service.dart';
import '../config/google_config.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Mr. Muffin');
  final TextEditingController _emailController = TextEditingController(text: 'mrmuffi@gmail.com'); // Sửa lại email hợp lệ
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId: kIsWeb ? GoogleConfig.webClientId : GoogleConfig.iOSClientId,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ====================== ĐĂNG KÝ/ĐĂNG NHẬP BẰNG GOOGLE ======================
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _showSnackBar("Không lấy được chứng thực từ Google.");
        return;
      }

      final result = await _authService.oauthLogin("google", idToken);

      String? token = result['accessToken'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng ký bằng Google thành công!"), backgroundColor: Colors.green),
          );
          // Navigator.pushReplacementNamed(context, '/home'); 
        }
      }
    } catch (e) {
      if (mounted) {
        String cleanError = e.toString().replaceAll('Exception: ', '');
        _showSnackBar("Google Sign-In thất bại: $cleanError");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ====================== ĐĂNG KÝ BÌNH THƯỜNG ======================
  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _passwordController.text.isEmpty) {
      _showSnackBar("Vui lòng điền đầy đủ thông tin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tách Name thành firstName và lastName
      List<String> nameParts = _nameController.text.trim().split(' ');
      String firstName = nameParts[0];
      String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await _authService.register(
        firstName,
        lastName,
        _emailController.text.trim(),
        _passwordController.text,
      );

      String? token = result['accessToken'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng ký thành công!"), backgroundColor: Colors.green),
          );
          // Chuyển về trang login hoặc trang chủ sau khi thành công
          // Navigator.pushReplacementNamed(context, '/login'); 
        }
      }
    } catch (e) {
      if (mounted) {
        String cleanError = e.toString().replaceAll('Exception: ', '');
        _showSnackBar(cleanError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                splashRadius: 24,
              ),
              const SizedBox(height: 32),

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

              // Nút SIGN UP (Đã kết nối với _handleRegister)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    elevation: 4,
                    shadowColor: const Color(0xFFDB3022).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
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
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                          child: _buildSocialButton('assets/images/button/google-icon.png'),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _showSnackBar("Facebook đang phát triển..."),
                          child: _buildSocialButton('assets/images/button/facebook-icon.png', isRounded: true),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
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
                borderRadius: BorderRadius.circular(4.0),
                child: Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.cover),
              )
            : Image.asset(
                assetPath,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    assetPath.contains('google') ? Icons.g_mobiledata : Icons.facebook,
                    size: 32,
                    color: Colors.grey,
                  );
                },
              ),
      ),
    );
  }
}
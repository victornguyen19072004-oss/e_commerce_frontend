import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'services/auth_service.dart';
import '../config/google_config.dart';
import 'home_page.dart'; // IMPORT LẠI HOME PAGE

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(text: 'muffin.sweet@gmail.com');
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isEmailValid = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
    clientId: GoogleConfig.iOSClientId,
    serverClientId: GoogleConfig.webClientId,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  // --- HÀM XỬ LÝ CHUYỂN TRANG AN TOÀN KÈM LOG ---
  void _onLoginSuccess(String message) {
    if (!mounted) return;
    
    debugPrint("=== [DEBUG]: Bắt đầu hàm _onLoginSuccess ===");
    debugPrint("=== [DEBUG]: Chuẩn bị hiện SnackBar ===");
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
    );

    debugPrint("=== [DEBUG]: Chuẩn bị chuyển sang HomePage ===");

    // Dùng pushAndRemoveUntil với MaterialPageRoute là cách an toàn và dứt khoát nhất
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        debugPrint("=== [DEBUG]: Đang thực thi lệnh Navigator.pushAndRemoveUntil ===");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        debugPrint("=== [DEBUG LỖI]: Widget đã unmounted trước khi kịp chuyển trang! ===");
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ====================== ĐĂNG NHẬP BÌNH THƯỜNG ======================
  Future<void> _handleLogin() async {
    if (!_isEmailValid || _emailController.text.trim().isEmpty) {
      _showSnackBar("Email không đúng định dạng");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập mật khẩu");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      String? token = result['accessToken'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        debugPrint("=== [DEBUG]: Đã lưu Token thành công ===");
        _onLoginSuccess("Đăng nhập thành công!");
        return; 
      } else {
        _showSnackBar("Không nhận được token xác thực từ máy chủ.");
      }
    } catch (e) {
      String cleanError = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(cleanError);
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  // ====================== ĐĂNG NHẬP BẰNG GOOGLE ======================
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
        setState(() => _isLoading = false);
        return;
      }

      final result = await _authService.oauthLogin("google", idToken);

      String? token = result['accessToken'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        _onLoginSuccess("Đăng nhập bằng Google thành công!");
        return;
      }
    } catch (e) {
      String cleanError = e.toString().replaceAll('Exception: ', '');
      _showSnackBar("Google Sign-In thất bại: $cleanError");
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  // ====================== ĐĂNG NHẬP BẰNG FACEBOOK ======================
  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult fbResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (fbResult.status == LoginStatus.success) {
        final AccessToken accessToken = fbResult.accessToken!;

        final result = await _authService.oauthLogin("facebook", accessToken.tokenString);

        String? token = result['accessToken'];
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          _onLoginSuccess("Đăng nhập bằng Facebook thành công!");
          return;
        }
      } else if (fbResult.status == LoginStatus.cancelled) {
         setState(() => _isLoading = false);
         return;
      } else {
        _showSnackBar("Lỗi Facebook: ${fbResult.message}");
      }
    } catch (e) {
      String cleanError = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(cleanError);
    }
    
    if (mounted) setState(() => _isLoading = false);
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

              const Text('Login', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 72),

              _buildTextField(
                label: 'Email', controller: _emailController, onChanged: _validateEmail, isError: !_isEmailValid,
                errorText: 'Not a valid email address. Should be your@email.com',
                suffixIcon: _isEmailValid
                    ? Image.asset('assets/images/icon/green-tick.png', width: 20, height: 20)
                    : Image.asset('assets/images/icon/red-tick.png', width: 20, height: 20),
              ),
              const SizedBox(height: 8),

              _buildTextField(label: 'Password', controller: _passwordController, isPassword: true),
              const SizedBox(height: 16),

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

              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022), elevation: 4,
                    shadowColor: const Color(0xFFDB3022).withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('LOGIN', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 140),

              Center(
                child: Column(
                  children: [
                    const Text('Or login with social account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(onTap: _isLoading ? null : _handleGoogleSignIn, child: _buildSocialButton('assets/images/button/google-icon.png')),
                        const SizedBox(width: 16),
                        GestureDetector(onTap: _isLoading ? null : _handleFacebookSignIn, child: _buildSocialButton('assets/images/button/facebook-icon.png', isRounded: true)),
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

  Widget _buildTextField({required String label, TextEditingController? controller, Widget? suffixIcon, bool isPassword = false, bool isError = false, String? errorText, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4),
            border: isError ? Border.all(color: Colors.red, width: 1.0) : null,
            boxShadow: [if (!isError) BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 1), blurRadius: 8)],
          ),
          child: TextFormField(
            controller: controller, obscureText: isPassword, onChanged: onChanged,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: label, labelStyle: TextStyle(color: isError ? Colors.red : Colors.grey, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none, floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: suffixIcon != null ? Padding(padding: const EdgeInsets.all(16.0), child: suffixIcon) : null,
            ),
          ),
        ),
        if (isError && errorText != null) Padding(padding: const EdgeInsets.only(top: 6.0, left: 16.0), child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }

  Widget _buildSocialButton(String assetPath, {bool isRounded = false}) {
    return Container(
      width: 92, height: 64,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Center(
        child: isRounded
            ? ClipRRect(borderRadius: BorderRadius.circular(4.0), child: Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.cover))
            : Image.asset(assetPath, width: 24, height: 24, errorBuilder: (context, error, stackTrace) => Icon(assetPath.contains('google') ? Icons.g_mobiledata : Icons.facebook, size: 32, color: Colors.grey)),
      ),
    );
  }
}

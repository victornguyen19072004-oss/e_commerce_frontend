import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Đường dẫn Backend đã deploy trên Render
  static const String baseUrl =
      "https://ecommerce-backend-8wur.onrender.com/api/auth";

  // 1. Logic Đăng ký (Email + Password)
  Future<Map<String, dynamic>> register(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Đăng ký thất bại.');
      } catch (_) {
        throw Exception('Email đã tồn tại hoặc lỗi máy chủ.');
      }
    }
  }

  // 2. Logic Đăng nhập (Email + Password)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      ); // Trả về Map chứa { accessToken, message }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại.');
      } catch (_) {
        throw Exception('Mật khẩu không đúng hoặc tài khoản không tồn tại.');
      }
    }
  }

  // 3. Logic Đăng nhập Mạng xã hội (Dùng chung cho cả Google & Facebook)
  Future<Map<String, dynamic>> oauthLogin(
    String provider,
    String idToken,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/oauth2/$provider'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "idToken": idToken, // Chỉ gửi idToken
        "provider": provider.toUpperCase(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['error'] ?? 'Đăng nhập mạng xã hội thất bại.',
        );
      } catch (_) {
        // Tự động viết hoa chữ cái đầu của provider để thông báo lỗi đẹp hơn (VD: facebook -> Facebook)
        String providerName =
            provider[0].toUpperCase() + provider.substring(1).toLowerCase();
        throw Exception('Lỗi kết nối đến máy chủ khi đăng nhập $providerName.');
      }
    }
  }
}

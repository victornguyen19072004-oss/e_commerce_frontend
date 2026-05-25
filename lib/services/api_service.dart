import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://ecommerce-wbg6.onrender.com"; // Real Device

  // Đăng ký
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    return _handleResponse(response);
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    return _handleResponse(response);
  }

  // OAuth2 (Google/Facebook)
  Future<Map<String, dynamic>> oauthLogin(
    String provider,
    String email,
    String name,
    String providerId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/auth/oauth2/$provider"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "name": name,
        "providerId": providerId,
      }),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Lỗi ${response.statusCode}: ${response.body}");
    }
  }
}

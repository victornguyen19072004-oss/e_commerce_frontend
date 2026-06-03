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
        return jsonDecode(response.body);
     } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Đăng nhập thất bại.');
        } catch (_) {
          throw Exception('Mật khẩu không đúng hoặc tài khoản không tồn tại.');
        }
     }
   }


   // 3. Logic Xác thực Mạng xã hội (Dùng chung cho Đăng ký & Đăng nhập)
   Future<Map<String, dynamic>> oauthLogin(
     String provider,
     String idToken,
   ) async {
     try {
        final response = await http.post(
          Uri.parse('$baseUrl/oauth2/$provider'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
             "idToken": idToken,
             "provider": provider.toUpperCase(),
          }),
        );


        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          // IN RA LỖI CHÍNH XÁC TỪ BACKEND ĐỂ DEBUG
          print("🚨 [BACKEND ERROR] Mã lỗi: ${response.statusCode}");
          print("🚨 [BACKEND ERROR] Nội dung: ${response.body}");


          String providerName =
               provider[0].toUpperCase() + provider.substring(1).toLowerCase();


          try {
             final errorData = jsonDecode(response.body);
             throw Exception(
               errorData['error'] ??
                    errorData['message'] ??
                    'Xác thực $providerName thất bại.',
             );
          } catch (_) {
             // Đã sửa lại thành chữ "Xác thực" để dùng chung cho cả Login và Sign Up
             throw Exception(
               'Hệ thống từ chối xác thực $providerName (Mã: ${response.statusCode}).',
             );
          }
        }
     } catch (e) {
        // Bắt luôn cả trường hợp điện thoại bị mất mạng (SocketException)
        if (e.toString().contains('SocketException')) {
          throw Exception(
             'Không thể kết nối đến máy chủ. Vui lòng kiểm tra Internet.',
          );
        }
        rethrow; // Ném lỗi lên UI
     }
   }
}
import 'package:flutter/material.dart';


class ForgotPasswordPage extends StatefulWidget {
   const ForgotPasswordPage({Key? key}) : super(key: key);


   @override
   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}


class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
   final TextEditingController _emailController = TextEditingController();
  
   bool _isEmailValid = false;
   bool _isEmailTouched = false;


   @override
   void dispose() {
     _emailController.dispose();
     super.dispose();
   }


   // Hàm kiểm tra định dạng email theo thời gian thực
   void _validateEmail(String value) {
     setState(() {
        _isEmailTouched = true;
        if (value.isEmpty) {
          _isEmailValid = false;
        } else {
          // Biểu thức chính quy kiểm tra định dạng email
          _isEmailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
        }
     });
   }


   @override
   Widget build(BuildContext context) {
     // Chỉ hiển thị lỗi khi người dùng đã gõ ký tự và định dạng không hợp lệ
     final bool showEmailError = _isEmailTouched && _emailController.text.isNotEmpty && !_isEmailValid;


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
                    'Forgot password',
                    style: TextStyle(
                       fontSize: 34,
                       fontWeight: FontWeight.bold, // In đậm tiêu đề
                       color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 87),


                  // Đoạn văn bản hướng dẫn
                  const Text(
                    'Please, enter your email address. You will receive a link to create a new password via email.',
                    style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.w500,
                       height: 1.4, // Tăng khoảng cách dòng cho dễ đọc
                    ),
                  ),
                  const SizedBox(height: 16),


                  // Form Nhập liệu Email với hiệu ứng Validation
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    onChanged: _validateEmail,
                    isError: showEmailError, // Kích hoạt UI viền đỏ khi có lỗi
                    errorText: 'Not a valid email address. Should be your@email.com',
                    suffixIcon: _emailController.text.isEmpty
                         ? null // Không hiện icon nếu ô trống
                         : _isEmailValid
                              ? Image.asset(
                                   'assets/images/icon/green-tick.png',
                                   width: 20,
                                   height: 20,
                                 )
                              : Image.asset(
                                   'assets/images/icon/red-tick.png',
                                   width: 20,
                                   height: 20,
                                 ),
                  ),
                  const SizedBox(height: 55),


                  // Nút SEND
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                       onPressed: () {
                         // Logic xử lý gửi email khôi phục mật khẩu
                         if (_isEmailValid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reset link sent to your email!')),
                            );
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFDB3022),
                         elevation: 4,
                         shadowColor: const Color(0xFFDB3022).withOpacity(0.4),
                         shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                         ),
                       ),
                       child: const Text(
                         'SEND',
                         style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                         ),
                       ),
                    ),
                  ),
               ],
             ),
          ),
        ),
     );
   }


   // Cấu trúc TextField hỗ trợ Error State (dùng chung logic với Login Page)
   Widget _buildTextField({
     required String label,
     TextEditingController? controller,
     Widget? suffixIcon,
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
               // Đổi viền sang màu đỏ nếu có lỗi
               border: isError ? Border.all(color: const Color(0xFFE82626), width: 1.0) : null,
               boxShadow: [
                  if (!isError) // Ẩn bóng mờ đi nếu đang ở trạng thái báo lỗi viền đỏ
                    BoxShadow(
                       color: Colors.black.withOpacity(0.05),
                       offset: const Offset(0, 1),
                       blurRadius: 8,
                    ),
               ],
             ),
             child: TextFormField(
               controller: controller,
               onChanged: onChanged,
               // Chữ nhập vào được in đậm
               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
               decoration: InputDecoration(
                  labelText: label,
                  // Label chuyển màu đỏ nếu báo lỗi
                  labelStyle: TextStyle(
                    color: isError ? const Color(0xFFE82626) : Colors.grey,
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
          ),
          // Hiển thị đoạn chữ báo lỗi ở bên dưới ô nhập
          if (isError && errorText != null)
             Padding(
               padding: const EdgeInsets.only(top: 6.0, left: 16.0),
               child: Text(
                  errorText,
                  style: const TextStyle(
                    color: Color(0xFFE82626),
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
               ),
             ),
        ],
     );
   }
}

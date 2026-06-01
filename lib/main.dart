import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'home_page.dart'; // Đừng quên import
// Import các màn hình
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';


// Cấu hình iPhone 11 Pro Max
// final DeviceInfo iphone11ProMax = DeviceInfo.genericPhone(
//   platform: TargetPlatform.iOS,
//   id: 'iphone-11-pro-max',
//   name: 'iPhone 11 Pro Max',
//   screenSize: const Size(414, 896),
//   pixelRatio: 3.0,
//   safeAreas: const EdgeInsets.only(top: 44, bottom: 34),
//   rotatedSafeAreas: const EdgeInsets.only(left: 44, right: 44, bottom: 21),
// );


void main() {
   SystemChrome.setSystemUIOverlayStyle(
     const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
     ),
   );


   runApp(
     // DevicePreview(
     //   enabled: !kReleaseMode,
     //   devices: [...Devices.all, iphone11ProMax],
     //   builder: (context) => const EcommerceApp(),
     // ),
     const EcommerceApp(),
   );
}


class EcommerceApp extends StatelessWidget {
   const EcommerceApp({Key? key}) : super(key: key);


   @override
   Widget build(BuildContext context) {
     return MaterialApp(
        title: 'E-Commerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Chỉnh nền xám rất nhẹ (#F9F9F9) để các form nhập liệu màu trắng nổi bật lên
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
          fontFamily: 'Metropolis',
        ),
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,


        // Đặt initialRoute là /signup để chạy thẳng vào màn hình Đăng ký
        initialRoute: '/signup',
        routes: {
          '/home': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/forgot': (context) => const ForgotPasswordPage(),
        },
     );
   }
}

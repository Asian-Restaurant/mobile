import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'AuthService.dart';
import 'firebase_options.dart';
import 'mobile/main_page_mobile.dart' as mobile;
import 'web/main_page_web.dart' as web;
import 'mobile/login_page_mobile.dart' as mobile_login;
import 'web/login_page_web.dart' as web_login;
import 'mobile/reviews_page_mobile.dart' as mobile_reviews;
import 'web/reviews_page_web.dart' as web_reviews;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Asian Paradise',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => kIsWeb ? web.MainPageWeb() : mobile.MainPageMobile(),
          '/login': (context) => kIsWeb ? const web_login.LoginPageWeb() : const mobile_login.LoginPageMobile(),
          '/reviews': (context) => kIsWeb ? const web_reviews.ReviewsPageWeb() : const mobile_reviews.ReviewsPageMobile(),
        },
      ),
    );
  }
}
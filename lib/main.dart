import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth/screens/login_screen.dart';
import 'package:flutter_firebase_auth/screens/signup_email_password_screen.dart';
import 'screens/login_email_password_screen.dart';
import 'screens/phone_screen.dart';


void main() async {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Firebase Auth Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginScreen(),
        routes: {
          EmailPasswordSignup.routeName: (context) =>
              const EmailPasswordSignup(),
          EmailPasswordLogin.routeName: (context) => const EmailPasswordLogin(),
          PhoneScreen.routeName: (context) => const PhoneScreen(),
        },
      );
  }
}



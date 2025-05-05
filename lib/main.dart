import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movirate/auth/auth_gate.dart';
import 'package:movirate/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        '/auth': (context) => AuthGate(),
      },
      initialRoute: '/auth',
    );
  }
}

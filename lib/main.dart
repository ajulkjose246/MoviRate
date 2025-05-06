import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movirate/auth/auth_gate.dart';
import 'package:movirate/auth/login_page.dart';
import 'package:provider/provider.dart';
import 'providers/recent_movies_provider.dart';
import 'providers/favorite_movies_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = FavoriteMoviesProvider();
            provider.startListening(); // Start listening for changes
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => RecentMoviesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const LoginPage(),
          '/auth': (context) => AuthGate(),
        },
        initialRoute: '/auth',
      ),
    );
  }
}

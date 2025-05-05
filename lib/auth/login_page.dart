// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'register_page.dart';
import '../services/firebase_auth_service.dart';
import 'auth_gate.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3E6EF),
              Color(0xFFD1D8F0),
              Color(0xFFF5F6FA),
            ], // Soft gray to light blue/lavender
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/MoviRate.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.black38),
                      prefixIcon: Icon(Icons.email, color: Color(0xFF5B5B8C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xFFB0B3C6)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.black38),
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF5B5B8C)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black38,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xFFB0B3C6)),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF5B5B8C)),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5B5B8C), // Muted blue accent
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 12,
                        shadowColor: Color(0xFF5B5B8C).withOpacity(0.2),
                      ),
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        if (email.isEmpty || password.isEmpty) {
                          toastification.show(
                            context: context,
                            title: Text('Please enter email and password.'),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) =>
                                  Center(child: CircularProgressIndicator()),
                        );
                        try {
                          await _authService.signInWithEmail(email, password);
                          Navigator.of(context).pop();
                        } catch (e) {
                          Navigator.of(context).pop();
                          String errorMsg = 'Login failed. Please try again.';
                          if (e is FirebaseAuthException) {
                            switch (e.code) {
                              case 'invalid-email':
                                errorMsg = 'Invalid email address.';
                                break;
                              case 'user-not-found':
                                errorMsg = 'User not found.';
                                break;
                              case 'wrong-password':
                                errorMsg = 'Wrong password.';
                                break;
                              case 'user-disabled':
                                errorMsg = 'User account is disabled.';
                                break;
                              default:
                                errorMsg = e.message ?? errorMsg;
                            }
                          }
                          toastification.show(
                            context: context,
                            title: Text(errorMsg),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                        }
                      },
                      child: Text('Login'),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Color(0xFFE0E0E0)),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      icon: Image.asset(
                        'assets/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: Text('Sign in with Google'),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) =>
                                  Center(child: CircularProgressIndicator()),
                        );
                        try {
                          final user = await _authService.signInWithGoogle();
                          Navigator.of(context).pop(); // Remove loading
                          if (user == null) {
                            toastification.show(
                              context: context,
                              title: Text('Google sign-in was cancelled.'),
                              autoCloseDuration: const Duration(seconds: 5),
                            );
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => AuthGate(),
                              ),
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          Navigator.of(context).pop(); // Remove loading
                          toastification.show(
                            context: context,
                            title: Text(
                              'Google sign-in failed. Please try again.',
                            ),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Write and share your movie reviews',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Color(0xFF5B5B8C)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

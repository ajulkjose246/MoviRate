import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '../auth/firebase_auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3E6EF), Color(0xFFD1D8F0), Color(0xFFF5F6FA)],
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
                    controller: _nameController,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.black38),
                      prefixIcon: Icon(Icons.person, color: Color(0xFF5B5B8C)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xFFB0B3C6)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(color: Colors.black38),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Color(0xFF5B5B8C),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black38,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xFFB0B3C6)),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5B5B8C),
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
                        final name = _nameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final confirmPassword =
                            _confirmPasswordController.text.trim();
                        if (name.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty ||
                            confirmPassword.isEmpty) {
                          toastification.show(
                            context: context,
                            title: Text('Please fill all fields.'),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                          return;
                        }
                        if (password != confirmPassword) {
                          toastification.show(
                            context: context,
                            title: Text('Passwords do not match.'),
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
                          await _authService.registerWithEmail(email, password);
                          Navigator.of(context).pop(); // Remove loading
                          // TODO: Navigate to home or main page
                        } catch (e) {
                          Navigator.of(context).pop(); // Remove loading
                          String errorMsg =
                              'Registration failed. Please try again.';
                          if (e is FirebaseAuthException) {
                            switch (e.code) {
                              case 'invalid-email':
                                errorMsg = 'Invalid email address.';
                                break;
                              case 'email-already-in-use':
                                errorMsg = 'Email is already in use.';
                                break;
                              case 'weak-password':
                                errorMsg = 'Password is too weak.';
                                break;
                              case 'operation-not-allowed':
                                errorMsg = 'Operation not allowed.';
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
                      child: Text('Register'),
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
                      label: Text('Sign up with Google'),
                      onPressed: () {
                        // TODO: Implement Google sign-in logic
                      },
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Join MoviRate and start sharing your movie reviews!',
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
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Already have an account? Login',
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

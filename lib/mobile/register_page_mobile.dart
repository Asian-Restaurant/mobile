import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:asian_paradise/mobile/main_page_mobile.dart';
import '../api/api_service.dart';

class RegisterPageMobile extends StatefulWidget {
  const RegisterPageMobile({super.key});

  @override
  _RegisterPageMobileState createState() => _RegisterPageMobileState();
}

class _RegisterPageMobileState extends State<RegisterPageMobile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final ApiService _apiService = ApiService('http://192.168.0.101:5000');

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink[100],
        title: Text(
          'WELCOME TO YOUR LITTLE DREAMWORLD',
          style: GoogleFonts.mali(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  filled: true,
                  fillColor: Colors.pink[50],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  filled: true,
                  fillColor: Colors.pink[50],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  filled: true,
                  fillColor: Colors.pink[50],
                ),
              ),
              const SizedBox(height: 10),
              // Поле для ввода пароля
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  filled: true,
                  fillColor: Colors.pink[50],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _repeatPasswordController,
                obscureText: _obscureRepeatPassword,
                decoration: InputDecoration(
                  labelText: 'Repeat Password',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                  filled: true,
                  fillColor: Colors.pink[50],
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureRepeatPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureRepeatPassword = !_obscureRepeatPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String name = _nameController.text;
                  String phone = _phoneController.text;
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  String repeatPassword = _repeatPasswordController.text;

                  if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
                    _showErrorDialog('Please fill in all fields.');
                    return;
                  }

                  if (password != repeatPassword) {
                    _showErrorDialog('Passwords do not match.');
                    return;
                  }

                  try {
                    await _apiService.registerUser({
                      'name': name,
                      'email': email,
                      'password': password,
                      'phone': phone,
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainPageMobile()),
                    );
                  } catch (e) {
                    _showErrorDialog('Registration failed: ${e.toString()}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[200],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Login', style: TextStyle(color: Colors.pink)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

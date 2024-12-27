import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import 'login_page_mobile.dart';

class AccountPageMobile extends StatefulWidget {
  final String email;

  const AccountPageMobile({Key? key, required this.email}) : super(key: key);

  @override
  _AccountPageMobileState createState() => _AccountPageMobileState();
}

class _AccountPageMobileState extends State<AccountPageMobile> {
  final ApiService _apiService = ApiService('http://192.168.0.101:5000');
  Map<String, dynamic>? userData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPageMobile()),
      );
    } else {
      await _loadUserData(email);
    }
  }

  Future<void> _loadUserData(String email) async {
    setState(() {
      _isLoading = true;
    });
    try {
      userData = await _apiService.getUser(email);
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPageMobile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink[100],
          title: Text(
            "Account",
            style: GoogleFonts.mali(color: Colors.black, fontSize: 24),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink[100],
        title: Text(
          "Account",
          style: GoogleFonts.mali(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome, ${userData?['name'] ?? 'User'}",
                  style: GoogleFonts.mali(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "Email: ${userData?['email'] ?? 'N/A'}",
                  style: GoogleFonts.mali(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Phone: ${userData?['phone'] ?? 'N/A'}",
                  style: GoogleFonts.mali(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[200],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

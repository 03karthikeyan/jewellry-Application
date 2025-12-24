import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sri_chandra_jewel/Screens/bottom_nav_page.dart';
import 'package:sri_chandra_jewel/Screens/registerScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

   @override
  void initState() {
    super.initState();
    _loadUserId();
  }


  // ✅ Load saved user ID when screen opens
 Future<void> _loadUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final storedId = prefs.getString('user_id');

  print('🔍 Loaded User ID: $storedId'); // Debug check

  if (storedId != null && storedId.isNotEmpty) {
    setState(() => userId = storedId);
    await fetchProfile();
  } else {
    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(
      msg: "User not logged in properly!",
      backgroundColor: Colors.red,
    );
  }
}


  // 🔹 Login function with validation & response handling
  Future<void> _loginWithMobile() async {
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    // ✅ Field validation
    if (mobile.isEmpty) {
      _showSnack('Please enter your mobile number');
      return;
    } else if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      _showSnack('Please enter a valid 10-digit mobile number');
      return;
    } else if (password.isEmpty) {
      _showSnack('Please enter your password');
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://pheonixconstructions.com/mobile/userLogin.php?password=$password&mobile=$mobile',
    );

    try {
      final response = await http.get(url);
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login API Response: $data');

        final success = data['success'];
        final message = data['message'].toString().toLowerCase();

        if (success == 1 && message.contains('login successful')) {
          final userId = data['data']['id'].toString();
          await _onLoginSuccessfully(userId);
          _showSnack('Login successful ✅', success: true);
        } else if (message.contains('not registered') ||
            message.contains('user not found')) {
          _showRegisterDialog(mobile);
        } else if (message.contains('incorrect password') ||
            message.contains('wrong password')) {
          _showSnack('Incorrect password. Please try again.');
        } else {
          _showSnack('Invalid credentials. Please check your details.');
        }
      } else {
        _showSnack('Server error. Please try again later.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Error: ${e.toString()}');
    }
  }

 // 🔹 Save userId locally & move to BottomNavPage
Future<void> _onLoginSuccessfully(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_id', userId);

  print('✅ Logged-in user ID saved locally: $userId');

  // Navigate & remove all previous routes
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => BottomNavPage()),
    (route) => false,
  );
}


  // 🔹 SnackBar for messages
  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: success ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 🔹 Register dialog
  void _showRegisterDialog(String mobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Colors.brown),
            SizedBox(width: 8),
            Text(
              'User Not Found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
          ],
        ),
        content: Text(
          'This mobile number is not registered.\nWould you like to register now?',
          style: TextStyle(fontSize: 16, color: Colors.brown.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterScreen(mobile: mobile),
                ),
              );
            },
            child: Text('REGISTER', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white70],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Logo / Title
                Text(
                  'Sri Chandra Jewel Crafts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    fontFamily: 'Serif',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Login with your mobile number',
                  style: TextStyle(fontSize: 16, color: Colors.brown.shade400),
                ),
                SizedBox(height: 30),

                // 🔹 Mobile field
                _buildTextField(
                  controller: _mobileController,
                  hint: 'Enter mobile number',
                  prefix: '+91 ',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: 16),

                // 🔹 Password field with toggle
                _buildTextField(
  controller: _passwordController,
  hint: 'Enter password',
  obscureText: _obscurePassword,
  prefixIcon: Icon(Icons.lock_outline, color: Colors.brown), // 👈 Added here
  suffixIcon: IconButton(
    icon: Icon(
      _obscurePassword
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      color: Colors.brown,
    ),
    onPressed: () {
      setState(() => _obscurePassword = !_obscurePassword);
    },
  ),
),

                SizedBox(height: 30),

                // 🔹 Continue button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: _isLoading ? null : _loginWithMobile,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                SizedBox(height: 30),

                // 🔹 Register now text
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen(mobile: '')),
                  ),
                  child: Text(
                    "Don't have an account? Register now",
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.brown.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (prefix != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(prefix,
                  style: TextStyle(
                      color: Colors.brown, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle:
                    TextStyle(fontSize: 16, color: Colors.brown.shade300),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
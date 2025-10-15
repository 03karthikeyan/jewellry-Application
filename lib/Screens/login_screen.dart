import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sri_chandra_jewel/Screens/registerScreen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginWithMobile() async {
    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty || mobile.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://afosindia.com/mobile/login.php?mobile=$mobile',
    );

    try {
      final response = await http.get(url);
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login API Response: $data');

        if (data['success'] == 1 &&
            data['message'].toString().toLowerCase() == 'success') {
          // User already registered, proceed to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OtpScreen(mobile: mobile)),
          );
        } else {
          //  User not found, show register prompt
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                  title: Row(
                    children: [
                      Icon(Icons.person_add_alt_1_rounded, color: Colors.brown),
                      SizedBox(width: 8),
                      Text(
                        'New User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'It looks like you are a new user.\nPlease register to continue.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  actionsPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.brown,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => RegisterScreen(mobile: mobile),
                          ),
                        );
                      },
                      child: Text(
                        'REGISTER',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login. Please try again.')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                'Login ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Login with your mobile number',
                style: TextStyle(fontSize: 16, color: Colors.brown.shade300),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.brown.shade300, width: 1),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.number,
                        maxLength: 10, // Restrict to 10 digits
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Only numbers allowed
                          LengthLimitingTextInputFormatter(
                            10,
                          ), // Limit to 10 digits
                        ],
                        decoration: InputDecoration(
                          counterText: "", // Hides the character counter
                          border: InputBorder.none,
                          hintText: 'Enter your mobile number',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.brown.shade300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 48),
                ),
                onPressed: _isLoading ? null : _loginWithMobile,
                child:
                    _isLoading
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
              SizedBox(height: 32),
              Text(
                'Or login with',
                style: TextStyle(fontSize: 14, color: Colors.brown.shade300),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialLoginButton(
                    icon: FontAwesomeIcons.facebook,
                    label: 'Facebook',
                    color: Colors.blue.shade800,
                    onTap: () {
                      // Your login logic here
                    },
                  ),
                  SizedBox(width: 16),
                  _buildSocialLoginButton(
                    icon: FontAwesomeIcons.instagram,
                    label: 'Instagram',
                    color: Colors.pink.shade400,
                    onTap: () {
                      // Your login logic here
                    },
                  ),

                  SizedBox(width: 16),
                  _buildSocialLoginButton(
                    icon: FontAwesomeIcons.google,
                    label: 'Google',
                    color: Colors.redAccent,
                    onTap: () {
                      // Your login logic here
                    },
                  ),
                ],
              ),

              SizedBox(height: 24),
              Column(
                children: [
                  Text(
                    'By continuing, you agree to our',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade300,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material(
                        color: Colors.transparent, // no background
                        child: InkWell(
                          onTap: () {
                            // Open Terms of Use
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 4,
                            ),
                            child: Text(
                              'Terms of Use',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' & ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown.shade300,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Open Privacy Policy
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 4,
                            ),
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Socialmedia based login method
Widget _buildSocialLoginButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap, // new param
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30), // ripple effect shape
    child: Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.brown)),
      ],
    ),
  );
}

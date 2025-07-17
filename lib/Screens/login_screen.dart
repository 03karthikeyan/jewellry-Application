import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      'http://pheonixconstructions.com/mobile/login.php?mobile=$mobile',
    );

    try {
      final response = await http.get(url);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        // You can print or parse the response here
        print('Response: ${response.body}');

        // Navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpScreen(mobile: '')),
        );
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
                'Login',
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
                    Expanded(
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
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
                      GestureDetector(
                        onTap: () {
                          // Open Terms of Use
                        },
                        child: Text(
                          'Terms of Use',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
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
                      GestureDetector(
                        onTap: () {
                          // Open Privacy Policy
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
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

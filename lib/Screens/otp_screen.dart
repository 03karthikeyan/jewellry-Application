import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'bottom_nav_page.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;

  const OtpScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isVerifying = false;

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a 4-digit OTP")));
      return;
    }

    setState(() => _isVerifying = true);

    final url = Uri.parse(
      'http://pheonixconstructions.com/mobile/login.php?mobile=${widget.mobile}&otp=$otp',
    );

    try {
      final response = await http.get(url);
      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        print("OTP Verified Response: ${response.body}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavPage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("OTP verification failed")));
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
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
              ),
              SizedBox(height: 16),
              Text(
                'OTP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please enter your 4 digit otp',
                style: TextStyle(fontSize: 16, color: Colors.brown.shade300),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.brown.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                    ),
                  );
                }),
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
                onPressed: _isVerifying ? null : _verifyOtp,
                child:
                    _isVerifying
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'VERIFY',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Haven’t Received OTP? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade300,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Optionally re-call the mobile API without OTP
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("OTP Resent")));
                    },
                    child: Text(
                      'Resend',
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
        ),
      ),
    );
  }
}

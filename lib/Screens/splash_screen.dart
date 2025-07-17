import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 4 seconds and navigate to the login screen
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            'Sri Chandra Jewel Crafts',
            style: TextStyle(
              fontFamily: 'Pacifico', // Use a custom font like Pacifico
              fontSize: 32, // Increase font size for better visibility
              fontWeight: FontWeight.w900, // Make it extra bold
              color: Colors.brown.shade700, // Use a rich brown color
              shadows: [
                Shadow(
                  offset: Offset(2, 2), // Add a shadow for depth
                  blurRadius: 4,
                  color: Colors.black26,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
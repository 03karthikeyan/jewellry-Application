import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jewellery/Screens/bottom_nav_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Splash duration

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null && userId.isNotEmpty) {
      // Already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavPage(),
        ), // Update this if needed
      );
    } else {
      // Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
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
              fontFamily: 'Pacifico',
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.brown.shade700,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
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

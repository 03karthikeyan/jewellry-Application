import 'package:flutter/material.dart';
import 'package:jewellery/Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'More',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.brown),
        //   onPressed: () {
        //     Navigator.pop(context); // Navigate back
        //   },
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Explore More Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            SizedBox(height: 16),

            // Options Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  MoreOptionCard(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    onTap: () {
                      // Navigate to About Us Page
                    },
                  ),
                  MoreOptionCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      // Navigate to Privacy Policy Page
                    },
                  ),
                  MoreOptionCard(
                    icon: Icons.rule,
                    title: 'Terms & Conditions',
                    onTap: () {
                      // Navigate to Terms and Conditions Page
                    },
                  ),
                  MoreOptionCard(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      // Navigate to Help & Support Page
                    },
                  ),
                  MoreOptionCard(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    onTap: () {
                      // Navigate to Feedback Page
                    },
                  ),
                  MoreOptionCard(
                    icon: Icons.star_border,
                    title: 'Rate Us',
                    onTap: () {
                      // Navigate to Rate Us functionality or app store
                    },
                  ),
                  MoreOptionCard(
                    icon: Icons.share,
                    title: 'Share App',
                    onTap: () {
                      // Share app functionality
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Logout'),
                        content: Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Close dialog first
                              Navigator.pop(context);
                              await Future.delayed(Duration(milliseconds: 300));
                              // Clear SharedPreferences
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('user_id');

                              // Navigate to login screen and remove all previous routes
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text('Logout'),
                          ),
                        ],
                      ),
                );
              },
              child: Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MoreOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.brown),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

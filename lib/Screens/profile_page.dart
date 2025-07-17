import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Profile Header Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile_picture.jpg'), // Default profile image
                    backgroundColor: Colors.brown.shade100,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kavin Kumar', // Replace with dynamic user name
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'kavin.kumar@example.com', // Replace with dynamic user email
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Profile Options Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ProfileOptionCard(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () {
                      // Navigate to Edit Profile Page
                    },
                  ),
                  ProfileOptionCard(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      // Navigate to Change Password Page
                    },
                  ),
                  ProfileOptionCard(
                    icon: Icons.history,
                    title: 'Order History',
                    onTap: () {
                      // Navigate to Order History Page
                    },
                  ),
                  ProfileOptionCard(
                    icon: Icons.location_on,
                    title: 'Manage Addresses',
                    onTap: () {
                      // Navigate to Manage Addresses Page
                    },
                  ),
                  ProfileOptionCard(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {
                      // Navigate to Notifications Settings
                    },
                  ),
                  ProfileOptionCard(
                    icon: Icons.settings,
                    title: 'Account Settings',
                    onTap: () {
                      // Navigate to Account Settings Page
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 48),
                ),
                onPressed: () {
                  // Handle Logout
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Logout'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Perform logout action and navigate to login screen
                            Navigator.pop(context); // Close dialog
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
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.brown.shade100,
            child: Icon(icon, color: Colors.brown),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ),
      ),
    );
  }
}
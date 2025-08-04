import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jewellery/Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '1';
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pheonixconstructions.com/mobile/profileFetch.php?user_id=$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          profileData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditProfileDialog() {
    final firstNameController = TextEditingController(
      text: profileData?['first_name'] ?? '',
    );
    final lastNameController = TextEditingController(
      text: profileData?['last_name'] ?? '',
    );
    final emailController = TextEditingController(
      text: profileData?['email'] ?? '',
    );
    String selectedGender = profileData?['gender'] ?? 'MALE';

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Edit Profile'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                        ),
                        TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(labelText: 'Gender'),
                          items:
                              ['MALE', 'FEMALE']
                                  .map(
                                    (gender) => DropdownMenuItem(
                                      value: gender,
                                      child: Text(gender),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) =>
                                  setDialogState(() => selectedGender = value!),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => _updateProfile(
                            firstNameController.text,
                            lastNameController.text,
                            emailController.text,
                            selectedGender,
                          ),
                      child: Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _updateProfile(
    String firstName,
    String lastName,
    String email,
    String gender,
  ) async {
    try {
      final url =
          'https://pheonixconstructions.com/mobile/profileUpdate.php'
          '?user_id=$userId'
          '&firstname=${Uri.encodeComponent(firstName)}'
          '&lastname=${Uri.encodeComponent(lastName)}'
          '&email=${Uri.encodeComponent(email)}'
          '&gender=${Uri.encodeComponent(gender)}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
        fetchProfile(); // Refresh profile data
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.brown),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.brown))
              : SingleChildScrollView(
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
                            backgroundImage: AssetImage(
                              'assets/profile_picture.jpg',
                            ),
                            backgroundColor: Colors.brown.shade100,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '${profileData?['firstname'] ?? 'Kavin'} ${profileData?['lastname'] ?? 'Kumar'}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            profileData?['phone'] ?? '+91 9876543210',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            profileData?['email'] ?? 'kavin.kumar@example.com',
                            style: TextStyle(
                              fontSize: 14,
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
                            onTap: () => _showEditProfileDialog(),
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
                          // ProfileOptionCard(
                          //   icon: Icons.location_on,
                          //   title: 'Manage Addresses',
                          //   onTap: () {
                          //     // Navigate to Manage Addresses Page
                          //   },
                          // ),
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
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Logout'),
                                  content: Text(
                                    'Are you sure you want to log out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(
                                            context,
                                          ), // Close dialog
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // Close the dialog first
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pop();

                                        // Clear user_id from SharedPreferences
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.remove('user_id');

                                        // Navigate to login and clear all previous routes
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              Navigator.of(
                                                context,
                                              ).pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          LoginScreen(),
                                                ),
                                                (route) => false,
                                              );
                                            });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

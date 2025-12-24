import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sri_chandra_jewel/Screens/login_screen.dart';
import 'package:sri_chandra_jewel/Screens/orders_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  void _showToast() {
    Fluttertoast.showToast(
      msg: "🚀 Coming Soon! This feature is under development.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.brown,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

 void _showEditProfileDialog() {
  final firstNameController = TextEditingController(
    text: profileData?['first_name']?.toString().trim() ?? '',
  );
  final lastNameController = TextEditingController(
    text: profileData?['last_name']?.toString().trim() ?? '',
  );
  final emailController = TextEditingController(
    text: profileData?['email']?.toString().trim() ?? '',
  );

  String selectedGender = profileData?['gender']?.toString().toUpperCase() ?? 'MALE';

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            titlePadding: EdgeInsets.only(top: 20, left: 24, right: 24),
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.brown),
                SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.brown[700],
                  ),
                ),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['MALE', 'FEMALE']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) => setDialogState(() {
                      selectedGender = value!;
                    }),
                  ),
                ],
              ),
            ),
            actionsPadding: EdgeInsets.only(right: 16, bottom: 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.save, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Close dialog only once
                  _updateProfile(
                    firstNameController.text.trim(),
                    lastNameController.text.trim(),
                    emailController.text.trim(),
                    selectedGender,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                label: Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      fetchProfile(); // refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating profile'),
        backgroundColor: Colors.red,
      ),
    );
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

                          //updated
                          // Text(
                          //   profileData?['name'] ?? 'User',
                          //   style: TextStyle(
                          //     fontSize: 22,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.brown,
                          //   ),
                          // ),
                          // SizedBox(height: 8),
                          // Text(
                          //   profileData?['mobile'] ?? '',
                          //   style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          // ),
                          // SizedBox(height: 4),
                          // Text(
                          //   profileData?['email'] ?? '',
                          //   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          // ),
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
                          // ProfileOptionCard(
                          //   icon: Icons.lock,
                          //   title: 'Change Password',
                          //   onTap: () {
                          //     // Navigate to Change Password Page
                          //   },
                          // ),
                          ProfileOptionCard(
                            icon: Icons.history,
                            title: 'Order History',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => OrdersPage()),
                              );
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
                            onTap: _showToast,
                          ),
                          ProfileOptionCard(
                            icon: Icons.settings,
                            title: 'Account Settings',
                            onTap: _showToast,
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

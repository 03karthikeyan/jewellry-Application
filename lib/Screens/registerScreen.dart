import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'bottom_nav_page.dart'; 

class RegisterScreen extends StatefulWidget {
  final String mobile;
  const RegisterScreen({required this.mobile, super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _gender = 'Male';
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final queryParams = {
      'mobile': widget.mobile,
      'firstname': _firstNameController.text.trim(),
      'lastname': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'gender': _gender,
      'password': _passwordController.text.trim(),
    };

    final uri = Uri.parse(
      'https://pheonixconstructions.com/mobile/userRegister.php',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri);

    print('API URL: $uri');
    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // ✅ SUCCESS CASE
      if (data['success'] == 1 &&
          data['message'].toString().toLowerCase().contains('success')) {
        final userId = data['data']?['id']?.toString() ?? '';

        if (userId.isNotEmpty) {
          // 🔹 Save user_id locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);
          print('✅ Registered User ID stored locally: $userId');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        // ✅ Navigate to BottomNavPage and clear previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BottomNavPage()),
          (route) => false,
        );
      }

      // ⚠️ MOBILE ALREADY EXISTS CASE
      else if (data['message']
              .toString()
              .toLowerCase()
              .contains('already registered') ||
          data['message'].toString().toLowerCase().contains('exists')) {
        _showAlreadyRegisteredDialog();
      }

      // ❌ OTHER FAILURES
      else {
        _showErrorDialog(data['message'] ?? 'Registration failed.');
      }
    } else {
      _showErrorDialog('Server error: ${response.statusCode}');
    }
  } catch (e) {
    _showErrorDialog('Network error. Please check your connection.');
    print('Error: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}


  // ⚠️ Alert for Already Registered Users
  void _showAlreadyRegisteredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Mobile Already Registered',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This mobile number is already registered. Would you like to login instead?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Go to Login',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ❌ Error Dialog for General Failures
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Registration Error',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.brown)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.brown) : null,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.brown),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.brown, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Register with your details to continue',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Input Fields
              _buildTextFields(),

              const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text(
                          'REGISTER',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?',
                      style: TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.brown),
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

  Column _buildTextFields() {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          decoration:
              _inputDecoration('First Name', icon: Icons.person_outline),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter your first name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: _inputDecoration('Last Name', icon: Icons.person),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Enter your last name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: _inputDecoration('Email', icon: Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Enter your email';
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: _inputDecoration('Password', icon: Icons.lock_outline),
          obscureText: true,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter password';
            if (v.length < 6) return 'Password must be at least 6 chars';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: _inputDecoration('Gender', icon: Icons.person_2),
          items: ['Male', 'Female', 'Other']
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _gender = v!),
        ),
      ],
    );
  }
}

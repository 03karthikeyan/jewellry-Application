import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'otp_screen.dart'; // Replace with actual import path

class RegisterScreen extends StatefulWidget {
  final String mobile;

  RegisterScreen({required this.mobile});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _gender = 'Male';

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToOtpScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OtpScreen(mobile: widget.mobile)),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare query parameters
      final queryParams = {
        'mobile': widget.mobile,
        'firstname': _firstNameController.text,
        'lastname': _lastNameController.text,
        'email': _emailController.text,
        'gender': _gender,
      };

      // Correctly construct full GET URI
      final uri = Uri.parse(
        'https://pheonixconstructions.com/mobile/userRegister.php',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);
      print('Register API status: ${response.statusCode}');
      print('Register API raw body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded Register Response: $data');

        if (data['success'] == 1 &&
            data['message'].toString().toLowerCase() == 'success') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Registration successful!')));
          await Future.delayed(Duration(milliseconds: 800));
          _navigateToOtpScreen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registration failed: ${data['message'] ?? 'Try again.'}',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your internet.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _register,
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Register'), backgroundColor: Colors.brown),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration('First Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter first name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration('Last Name'),
                validator: (value) => value!.isEmpty ? 'Enter last name' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value!.isEmpty || !value.contains('@')
                            ? 'Enter valid email'
                            : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _inputDecoration('Gender'),
                items:
                    ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'REGISTER',
                            style: TextStyle(fontSize: 16, letterSpacing: 1),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

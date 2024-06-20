import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreenForTourist extends StatefulWidget {
  const SignUpScreenForTourist({Key? key}) : super(key: key);

  @override
  _SignUpScreenForTouristState createState() => _SignUpScreenForTouristState();
}

class _SignUpScreenForTouristState extends State<SignUpScreenForTourist> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emergencyPhoneNoController =
      TextEditingController();
  final TextEditingController _emergencyEmailController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _genderValue;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign up as Tourist',
          style: TextStyle(color: Colors.white),
        ),
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please enter your details:'),
              const SizedBox(height: 10),
              _buildTextField(_firstNameController, 'First Name'),
              const SizedBox(height: 10),
              _buildTextField(_lastNameController, 'Last Name'),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email',
                  inputType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _buildTextField(_contactNoController, 'Contact Number',
                  inputType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField(_countryController, 'Country'),
              const SizedBox(height: 10),
              _buildDropdownField(),
              const SizedBox(height: 10),
              _buildTextField(_ageController, 'Age',
                  inputType: TextInputType.number),
              const SizedBox(height: 10),
              _buildTextField(_passwordController, 'Password',
                  isPassword: true),
              const SizedBox(height: 10),
              _buildTextField(
                  _emergencyPhoneNoController, 'Emergency Contact Phone Number',
                  inputType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField(
                  _emergencyEmailController, 'Emergency Contact Email',
                  inputType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildSignUpButton(),
              const SizedBox(height: 20),
              _buildLoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: inputType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _genderValue,
      onChanged: (String? newValue) {
        setState(() {
          _genderValue = newValue;
        });
      },
      items: <String>['Male', 'Female', 'Others']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select your gender';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 70),
      child: Column(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
              backgroundColor: const Color(0xFFA1662f),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _isLoading ? null : _handleSignUp,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Sign Up as Tourist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Already have an account? ",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            TextSpan(
              text: "Login Here",
              style: const TextStyle(color: Color(0xFFA1662f), fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, '/login');
                },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String url = 'https://tokma.onrender.com/api/tourist/register';

      Map<String, dynamic> userData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'contactNo': _contactNoController.text,
        'country': _countryController.text,
        'gender': _genderValue,
        'age': int.parse(_ageController.text),
        'password': _passwordController.text,
        'emergencyNumber': _emergencyPhoneNoController.text,
        'emergencyEmail': _emergencyEmailController.text,
      };

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(userData),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          Navigator.pushNamed(context, '/login');
        } else {
          _showSnackBar('Signup Failed: ${response.body}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error: $e');
      }
    } else {
      _showSnackBar('Please fill all the required fields');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

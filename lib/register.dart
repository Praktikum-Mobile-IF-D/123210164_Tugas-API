import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _birthdayController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _password1Controller.text.isEmpty ||
        _birthdayController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    if (_passwordController.text != _password1Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    if (!_isEmailValid(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid email format!")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];

    // Check for duplicate email
    if (users.any((user) => user.split('|')[0] == _emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email already exists!")),
      );
      return;
    }

    // Add new user
    final newUser = '${_emailController.text}|${_passwordController.text}|${_nameController.text}|${_birthdayController.text}|${_addressController.text}';
    users.add(newUser);
    prefs.setStringList('users', users);
    prefs.setBool('isLoggedIn', true);
    prefs.setString('loggedInUser', _emailController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration successful! Please log in.")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  bool _isEmailValid(String email) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    return email.isNotEmpty && regex.hasMatch(email);
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      ),
    );
  }

  Widget _buildBirthdayField() {
    return TextFormField(
      controller: _birthdayController,
      decoration: InputDecoration(
        hintText: 'Birthday',
        prefixIcon: Icon(Icons.cake, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      readOnly: true,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1945),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _birthdayController.text = formattedDate;
      });
    } else {
      print("Date is not selected");
    }
  }

  Widget _buildButton(String text, void Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.pinkAccent[100],
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        color: Color(0xFFFFF7F5),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 40),
                _buildTextField(_emailController, 'Email', Icons.email),
                SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', Icons.lock_outline, isPassword: true),
                SizedBox(height: 20),
                _buildTextField(_password1Controller, 'Repeat Password', Icons.lock_outline, isPassword: true),
                SizedBox(height: 20),
                _buildTextField(_nameController, 'Name', Icons.person),
                SizedBox(height: 20),
                _buildTextField(_addressController, 'Address', Icons.home),
                SizedBox(height: 20),
                _buildBirthdayField(),
                SizedBox(height: 30),
                _buildButton('Register', () => _register(context)),
                SizedBox(height: 10),
                _buildButton('Login', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

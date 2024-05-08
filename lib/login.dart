import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  void _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final userList = prefs.getStringList('users') ?? [];

    final isUserValid = userList.any((user) {
      final parts = user.split('|');
      return parts[0] == email && parts[1] == password;
    });

    if (isUserValid) {
      prefs.setBool('isLoggedIn', true);
      prefs.setString('loggedInUser', email);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid email or password.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
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
                SizedBox(height: 30),
                _buildButton('Login', () => _login(context)),
                SizedBox(height: 10),
                _buildButton('Register', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

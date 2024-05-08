import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, String>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('loggedInUser') ?? 'Unknown';
    final users = prefs.getStringList('users') ?? [];
    final user = users.firstWhere((user) => user.split('|')[0] == email, orElse: () => '');

    if (user.isNotEmpty) {
      final parts = user.split('|');
      return {
        'Name': parts[2],
        'Email': parts[0],
        'Birthday': parts[3],
        'Address': parts[4],
      };
    }

    return {
      'Name': 'Unknown',
      'Email': 'Unknown',
      'Birthday': 'Unknown',
      'Address': 'Unknown',
    };
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('loggedInUser');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout successful!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent[100],
        title: Text('Profile'),
      ),
      body: Container(
        color: Color(0xFFFFF7F5),
        child: Center(
          child: FutureBuilder<Map<String, String>>(
            future: _loadUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                final data = snapshot.data!;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    ),
                    SizedBox(height: 20),
                    Text('Name: ${data['Name']}'),
                    SizedBox(height: 8),
                    Text('Email: ${data['Email']}'),
                    SizedBox(height: 8),
                    Text('Birthday: ${data['Birthday']}'),
                    SizedBox(height: 8),
                    Text('Address: ${data['Address']}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.pinkAccent[100],
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Text('Error loading profile');
              }
            },
          ),
        ),
      ),
    );
  }
}

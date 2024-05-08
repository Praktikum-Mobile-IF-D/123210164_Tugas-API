import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data!) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('email');
  }
}

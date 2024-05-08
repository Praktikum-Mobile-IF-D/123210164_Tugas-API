import 'package:flutter/material.dart';
import 'detail.dart';
import 'profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['categories'];
      });
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent[100],
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _openProfile,
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFFFF7F5),
        child: categories.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Card(
              color: Colors.pink[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.all(10),
              elevation: 5,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: Image.network(
                  category['strCategoryThumb'],
                  width: 80,
                  height: 80,
                ),
                title: Text(
                  category['strCategory'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  category['strCategoryDescription'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        categoryName: category['strCategory'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

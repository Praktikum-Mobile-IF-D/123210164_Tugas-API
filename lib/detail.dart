import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final String categoryName;

  DetailPage({required this.categoryName});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List meals = [];

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.categoryName}'));
    if (response.statusCode == 200) {
      setState(() {
        meals = json.decode(response.body)['meals'];
      });
    }
  }

  void fetchMealDetail(String mealId) async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId'));
    if (response.statusCode == 200) {
      final mealDetail = json.decode(response.body)['meals'][0];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailPage(mealDetail: mealDetail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent[100],
        title: Text('${widget.categoryName} Meals'),
      ),
      body: Container(
        color: Color(0xFFFFF7F5),
        child: meals.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
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
                  meal['strMealThumb'],
                  width: 80,
                  height: 80,
                ),
                title: Text(
                  meal['strMeal'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () => fetchMealDetail(meal['idMeal']),
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> launchURL(String url) async {
  final Uri _url = Uri.parse(url);
  if (!await launchUrl(_url)) {
    throw "Couldn't launch URL";
  }
}

class MealDetailPage extends StatelessWidget {
  final Map<String, dynamic> mealDetail;

  MealDetailPage({required this.mealDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent[100],
        title: Text(mealDetail['strMeal']),
      ),
      body: Container(
        color: Color(0xFFFFF7F5),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  mealDetail['strMeal'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    mealDetail['strMealThumb'],
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Category: ${mealDetail['strCategory']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Area: ${mealDetail['strArea']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Instructions:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        mealDetail['strInstructions'],
                        style: TextStyle(fontSize: 16),
                      ),
                      if (mealDetail['strYoutube'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: InkWell(
                            child: Text(
                              'Watch on YouTube: ${mealDetail['strYoutube']}',
                              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                            ),
                            // Use the new global launchURL method here
                            onTap: () => launchURL(mealDetail['strYoutube']),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

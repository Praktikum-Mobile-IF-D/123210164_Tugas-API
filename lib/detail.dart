import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final int mangaId;

  DetailPage({required this.mangaId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic> mangaDetails = {};

  @override
  void initState() {
    super.initState();
    fetchMangaDetails();
  }

  Future<void> fetchMangaDetails() async {
    final response = await http.get(Uri.parse('https://api.jikan.moe/v4/manga/${widget.mangaId}/full'));
    if (response.statusCode == 200) {
      setState(() {
        mangaDetails = json.decode(response.body)['data'];
      });
    } else {
      print('Failed to load manga details');
    }
  }

  Widget buildTextSection(String label, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }

  Widget buildLinkSection(String label, List<dynamic> items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Column(
            children: items.map<Widget>((item) => InkWell(
              onTap: () => _launchURL(item['url']),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text(item['name'], style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await canLaunchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not launch $url'),
      ));
    } else {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent[100],
        title: Text(mangaDetails.isNotEmpty ? mangaDetails['title'] : 'Loading...'),
      ),
      body: mangaDetails.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFF7F5),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(mangaDetails['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24), textAlign: TextAlign.center),
              SizedBox(height: 20),
              Image.network(mangaDetails['images']['jpg']['large_image_url'], fit: BoxFit.contain, height: 200),
              SizedBox(height: 20),
              buildTextSection("Synopsis", mangaDetails['synopsis']),
              buildTextSection("Background", mangaDetails['background']),
              buildTextSection("Publishing Dates", mangaDetails['published']['string']),
              buildTextSection("Score", mangaDetails['score'].toString()),
              buildTextSection("Rank", mangaDetails['rank'].toString()),
              buildTextSection("Popularity", mangaDetails['popularity'].toString()),
              if (mangaDetails['authors'] != null)
                buildLinkSection("Authors", mangaDetails['authors']),
              if (mangaDetails['genres'] != null)
                buildLinkSection("Genres", mangaDetails['genres']),
              if (mangaDetails['themes'] != null)
                buildLinkSection("Themes", mangaDetails['themes']),
              if (mangaDetails['demographics'] != null)
                buildLinkSection("Demographics", mangaDetails['demographics']),
              if (mangaDetails['serializations'] != null)
                buildLinkSection("Serialized In", mangaDetails['serializations']),
              if (mangaDetails['relations'] != null)
                buildLinkSection("Related Anime", mangaDetails['relations'][0]['entry']),
              if (mangaDetails['external'] != null)
                buildLinkSection("External Links", mangaDetails['external']),
              if (mangaDetails['url'] != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Text('More Info', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    onPressed: () => _launchURL(mangaDetails['url']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

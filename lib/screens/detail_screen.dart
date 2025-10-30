import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String movieTitle;
  final String imageUrl;
  final String movieSubtitle;

  const DetailScreen({
    super.key,
    required this.movieTitle,
    required this.imageUrl,
    required this.movieSubtitle,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movieTitle),
      ),

      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              movieSubtitle,
              style: const TextStyle(fontSize:18 ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}
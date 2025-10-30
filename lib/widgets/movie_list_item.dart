import 'package:flutter/material.dart';
import 'package:movie_app_sertifikasi/screens/detail_screen.dart';


class MovieListItem extends StatelessWidget {
  final String imgUrl;
  final String title;
  final String subtitle;

  const MovieListItem({
    super.key,
    required this.imgUrl,
    required this.title,
    required this.subtitle
    });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(
        imgUrl,
        width: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, StackTrace){
          return Icon(Icons.movie, size: 50);
        },
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: (){
        Navigator.push(context,
        MaterialPageRoute(
          builder:(context) => DetailScreen(
            movieTitle: title, 
            imageUrl: imgUrl, 
            movieSubtitle: subtitle
            ),
          ),
        );
      },
    );
  }
}
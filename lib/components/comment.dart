import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String author;
  final String time;

  const Comment(
      {super.key,
      required this.text,
      required this.author,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          Row(
            children: [
              Text(author, style: TextStyle(color: Colors.grey[600])),
              Text(" • ", style: TextStyle(color: Colors.grey[600])),
              Text(time, style: TextStyle(color: Colors.grey[600]))
            ],
          ),
        ],
      ),
    );
  }
}

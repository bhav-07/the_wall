import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/like_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      required this.postId,
      required this.likes});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //access the document on firebase
    DocumentReference postReference =
        FirebaseFirestore.instance.collection("User Posts").doc(widget.postId);

    if (isLiked) {
      postReference.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postReference.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            children: [
              LikeButton(
                isLiked: isLiked,
                onTap: toggleLike,
              ),
              const SizedBox(height: 10),
              Text(
                widget.likes.length.toString(),
                style: const TextStyle(color: Colors.grey),
              )
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message, style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    widget.user,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.circle_sharp, size: 5, color: Colors.grey),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

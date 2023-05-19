import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment.dart';
import 'package:the_wall/components/comment_button.dart';
import 'package:the_wall/components/like_button.dart';
import 'package:the_wall/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final String postTimeStamp;
  final List<String> likes;
  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      required this.postId,
      required this.likes,
      required this.postTimeStamp});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  //comment text controller
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
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

  //add a comment
  void addComment(String commentText) {
    //write the comment to firestore under the  comments collection for the post
    if (_commentController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("User Posts")
          .doc(widget.postId)
          .collection("Comments")
          .add({
        'CommentText': commentText,
        'CommentBy': currentUser.email,
        'CommentTime': Timestamp.now() //! format this
      });
    }
    ;
  }

  //dialog box to input comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a comment"),
        content: TextField(
          controller: _commentController,
          decoration: const InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          //cancel button
          TextButton(
              onPressed: () =>
                  {Navigator.pop(context), _commentController.clear()},
              child: const Text("Cancel")),
          //save button
          TextButton(
              onPressed: () => {
                    addComment(_commentController.text),
                    _commentController.clear(),
                    Navigator.pop(context)
                  },
              child: const Text("Post")),
        ],
      ),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  const SizedBox(width: 8),
                  const Icon(Icons.circle_sharp, size: 5, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(widget.postTimeStamp,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //* Like button
              Column(
                children: [
                  //like button
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toggleLike,
                  ),
                  const SizedBox(height: 10),
                  //like count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
              const SizedBox(width: 10),
              //* Comment Button
              Column(
                children: [
                  //like button
                  CommentButton(onTap: showCommentDialog),
                  const SizedBox(height: 10),
                  //like count
                  const Text("0",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          //* comments under the post
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                shrinkWrap: true, //! for nested lists
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  //get the comment from firebase
                  final commentData = doc.data() as Map<String, dynamic>;
                  return Comment(
                      text: commentData["CommentText"],
                      author: commentData["CommentBy"],
                      time: formatDate(commentData["CommentTime"]));
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

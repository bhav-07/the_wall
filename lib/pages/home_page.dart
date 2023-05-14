import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/text_field.dart';
import 'package:the_wall/components/wall_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user info
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller for post a message
  final textController = TextEditingController();

  //post the message
  void postMessage() {
    //only post if there is something is there in the textfield
    if (textController.text.isNotEmpty) {
      //store it in firebase
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    //clear the textfield
    setState(() {
      textController.clear();
    });
  }

  void signout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("The Wall"),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: [
          //sign out button
          IconButton(onPressed: signout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            //the wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the messages
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error:${snapshot.error}"),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            //post a message
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                      child: MyTextField(
                          controller: textController,
                          hintText: 'Post something on the wall..',
                          obscureText: false)),
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),
            //logged in as
            Text(
              "Logged in as: ${currentUser.email}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

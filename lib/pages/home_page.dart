import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_wall/components/drawer.dart';
import 'package:the_wall/components/text_field.dart';
import 'package:the_wall/components/wall_post.dart';
import 'package:the_wall/helper/helper_methods.dart';
import 'package:the_wall/pages/profile_page.dart';

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
  //navigate to profile page
  void goToProfilePage() {
    Navigator.pop(context); 
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("The Wall",style: GoogleFonts.pacifico(fontSize: 25),),
        elevation: 0,
        centerTitle: true,
        
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOutTap: signout,
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
                          postTimeStamp: formatDate(post['TimeStamp']),
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
                      icon: const Icon(Icons.arrow_upward_rounded))
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

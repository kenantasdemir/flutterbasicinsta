import 'package:flutter/material.dart';
import 'package:instagramcloneapp/view_models/user_view_model.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
  TextEditingController();
  void postComment(String uid, String name, String profilePic) async {
    try {
      await Provider.of<UserViewModel>(context, listen: false).postComment(
        widget.postId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );
      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<UserViewModel>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Yorumlar',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: mobileBackgroundColor,
      body: Consumer<UserViewModel>(
        builder: (context, userViewModel, _) {
          return StreamBuilder<List<Comment>>(
            stream: userViewModel.getCommentsStream(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final comments = snapshot.data ?? [];
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (ctx, index) => CommentCard(
                  comment: comments[index],
                  dark: true,
                ),
              );
            },
          );
        },
      ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Düşüncelerini paylaş',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postComment(
                  user.uid,
                  user.username,
                  user.photoUrl,
                ),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Gönder',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
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
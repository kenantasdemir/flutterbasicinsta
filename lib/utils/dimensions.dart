import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/add_post_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import 'colors.dart';

const webScreenSize = 600;


List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  Scaffold(
    backgroundColor: mobileBackgroundColor,
    body: AddPostScreen(),
  ),
  Scaffold(
    backgroundColor: mobileBackgroundColor,
    appBar: AppBar(
      backgroundColor: mobileBackgroundColor,
      title: const Text('notifications', style: TextStyle(color: Colors.white)),
      elevation: 0,
    ),
    body: const Center(
      child: Icon(Icons.notifications, color: Colors.white54, size: 48),
    ),
  ),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];


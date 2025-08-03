import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:instagramcloneapp/services/firebase_storage_service.dart";
import 'package:uuid/uuid.dart';

import "../locator.dart";
import "../models/post.dart";
import "../models/user.dart" as userModel;
import "../models/comment.dart";

class FirebaseFirestoreService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService storageService = locator<FirebaseStorageService>();



  Future<bool> uploadPost(String uid,String username, String profImage,String description, Uint8List file,
      ) async {

    try {
      String photoUrl =
      await storageService.uploadImageToStorage( file, true);
      final String postId = const Uuid().v4();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
    } catch (err) {
    }

    return true;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    if (text.isEmpty) throw Exception("Please enter text");
    String commentId = const Uuid().v1();
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .set({
      'profilePic': profilePic,
      'name': name,
      'uid': uid,
      'text': text,
      'commentId': commentId,
      'datePublished': DateTime.now(),
    });
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
      await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<void> savePost(String userId, String postId) async {
    await _firestore.collection('users').doc(userId).update({
      'savedPosts': FieldValue.arrayUnion([postId])
    });
  }

  Future<void> unsavePost(String userId, String postId) async {
    await _firestore.collection('users').doc(userId).update({
      'savedPosts': FieldValue.arrayRemove([postId])
    });
  }

  Future<List<userModel.MyUser>> searchUsersByUsername(String username) async {
    final snap = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .get();
    return snap.docs.map((doc) => userModel.MyUser.fromMap(doc.data())).toList();
  }

  Future<List<Post>> getRecentPosts() async {
    final snap = await _firestore
        .collection('posts')
        .orderBy('datePublished')
        .get();
    return snap.docs.map((doc) => Post.fromSnap(doc)).toList();
  }

  Future<List<Post>> getPostsByUid(String uid) async {
    final snap = await _firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .get();
    return snap.docs.map((doc) => Post.fromSnap(doc)).toList();
  }

  Future<List<Post>> getPostsByIds(List ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final snap = await _firestore
        .collection('posts')
        .where('postId', whereIn: ids.length > 10 ? ids.sublist(0, 10) : ids)
        .get();
    return snap.docs.map((doc) => Post.fromSnap(doc)).toList();
  }

  Future<List<Post>> getLikedPosts(String uid) async {
    final snap = await _firestore
        .collection('posts')
        .where('likes', arrayContains: uid)
        .get();
    return snap.docs.map((doc) => Post.fromSnap(doc)).toList();
  }

  Future<userModel.MyUser?> getUserByUid(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return userModel.MyUser.fromMap(snap.data()!);
  }


  Future<userModel.MyUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final snapshot =
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!snapshot.exists) return null;

    return userModel.MyUser.fromMap(snapshot.data()!);
  }


  Future<userModel.MyUser?> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
    await _firestore.collection("users").doc(userID).get();

    final data = _okunanUser.data();
    if (data != null && data is Map<String, dynamic>) {
      return userModel.MyUser.fromMap(data);
    } else {
      return null;
    }
  }

  Future<void> unfollowUser(String id, String targetId) async {

  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Comment.fromSnap(doc)).toList());
  }

}
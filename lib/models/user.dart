import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MyUser {
  final String? email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final List savedPosts;

  const MyUser({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    required this.savedPosts,
  });

  static MyUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return MyUser(
      username: snapshot["username"] ?? "",
      uid: snapshot["uid"] ?? Uuid().v1(),
      email: snapshot["email"] ?? "",
      photoUrl: snapshot["photoUrl"] ??"",
      bio: snapshot["bio"]??  "",
      followers: snapshot["followers"]??[],
      following: snapshot["following"]??[],
      savedPosts: snapshot["savedPosts"]??[],
    );
  }

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "email": email,
    "photoUrl": photoUrl,
    "bio": bio,
    "followers": followers,
    "following": following,
    "savedPosts": savedPosts,
  };

  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(
      uid: map['uid'] ?? Uuid().v1(),
      email: map['email'] ?? "",
      username: map['username'] ?? "",
      bio: map['bio'] ?? "",
      photoUrl: map["photoUrl"]??"",
      followers: map["followers"]??[],
      following: map["following"]??[],
      savedPosts: map["savedPosts"]??[],
    );
  }
}

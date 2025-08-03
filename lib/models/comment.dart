import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String uid;
  final String name;
  final String profilePic;
  final String text;
  final DateTime datePublished;

  Comment({
    required this.commentId,
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.text,
    required this.datePublished,
  });

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Comment(
      commentId: snapshot['commentId'] ?? '',
      uid: snapshot['uid'] ?? '',
      name: snapshot['name'] ?? '',
      profilePic: snapshot['profilePic'] ?? '',
      text: snapshot['text'] ?? '',
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(),
    );
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['commentId'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      text: map['text'] ?? '',
      datePublished: (map['datePublished'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'commentId': commentId,
    'uid': uid,
    'name': name,
    'profilePic': profilePic,
    'text': text,
    'datePublished': datePublished,
  };
} 
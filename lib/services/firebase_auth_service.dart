import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagramcloneapp/services/firebase_storage_service.dart';
import "package:instagramcloneapp/models/user.dart" as userModel;


class FirebaseAuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorageService firebaseStorageService = FirebaseStorageService();

  Future<userModel.MyUser> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        bio.isEmpty ||
        file.isEmpty) {
      throw Exception("Lütfen tüm alanları doldurun");
    }

    UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("Kullanıcı oluşturuldu: ${cred.user!.uid}");

    String photoUrl =
        await firebaseStorageService.uploadImageToStorage(file, false);
    print("Fotoğraf yüklendi: $photoUrl");

    userModel.MyUser user = userModel.MyUser(
        username: username,
        uid: cred.user!.uid,
        photoUrl: photoUrl,
        email: email,
        bio: bio,
        followers: [],
        following: [],
        savedPosts: []);

    await firebaseFirestore
        .collection("users")
        .doc(cred.user!.uid)
        .set(user.toJson());

    return user;
  }




  Future<UserCredential> signInUser({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }




  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}

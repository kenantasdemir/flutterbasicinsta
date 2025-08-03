import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagramcloneapp/repository/user_repository.dart';
import 'package:provider/provider.dart';

import '../locator.dart';
import '../models/user.dart' as userModel;
import '../models/post.dart';
import '../models/comment.dart';

enum ViewState { Idle, Busy }

class UserViewModel with ChangeNotifier {
  ViewState _state = ViewState.Idle;
  ViewState get state => _state;

  userModel.MyUser? _user;

  userModel.MyUser? get getUser => _user;

  final UserRepository userRepository = locator<UserRepository>();

  UserModel() {
    getCurrentUser();
  }


    set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  Future<userModel.MyUser?> signUpUser(
    String email,
    String password,
    String username,
    String bio,
    Uint8List file,
  ) async {
    // try-catch bloğu kaldırıldı. Hata yönetimi UI katmanına bırakıldı.
    state = ViewState.Busy;
    _user = await userRepository.signUpUser(
      email: email,
      password: password,
      username: username,
      bio: bio,
      file: file,
    );
    state = ViewState.Idle;
    return _user;
  }

  Future<void> signInUser(String email, String password) async {
    state = ViewState.Busy;
    _user = await userRepository.signInUser(email: email, password: password);
    state = ViewState.Idle;
    notifyListeners();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsStream() {
    return FirebaseFirestore.instance.collection('posts').snapshots();
  }

  Future<userModel.MyUser?> getCurrentUser() async {

    try{
 state = ViewState.Busy;
   _user = await userRepository.getCurrentUser();
     return _user;
    }catch( e){
      return null;
    }finally{
    state = ViewState.Idle;
    }
  
  }




  Future<bool> uploadPost(
    String text,
    Uint8List uint8list,
    String uid,
    String username,
    String profImage,
  ) async {
    return await userRepository.uploadPost(
      uid,
      profImage,
      username,
      text,
      uint8list,
    );
  }

  Future<void> followUser(String id, String targetId) async {
    return userRepository.followUser(id, targetId);
  }

  Future<void> savePost(String postId) async {
    if (_user == null) return;
    await userRepository.savePost(_user!.uid, postId);
    _user = await userRepository.getCurrentUser();
    notifyListeners();
  }

  Future<void> unsavePost(String postId) async {
    if (_user == null) return;
    await userRepository.unsavePost(_user!.uid, postId);
    _user = await userRepository.getCurrentUser();
    notifyListeners();
  }

  Future<List<userModel.MyUser>> searchUsersByUsername(String username) async {
    return await userRepository.searchUsersByUsername(username);
  }

  Future<List<Post>> getRecentPosts() async {
    return await userRepository.getRecentPosts();
  }

  Future<List<Post>> getPostsByUid(String uid) async {
    return await userRepository.getPostsByUid(uid);
  }

  Future<List<Post>>  getPostsByIds(List ids) async {
    return await userRepository.getPostsByIds(ids);
  }

  Future<List<Post>> getLikedPosts(String uid) async {
    return await userRepository.getLikedPosts(uid);
  }

  Future<userModel.MyUser?> getUserByUid(String uid) async {
    return await userRepository.getUserByUid(uid);
  }

  Future<void> unfollowUser(String id, String targetId) async {
    return userRepository.unfollowUser(id, targetId);
  }

  Future<void> signOut() async{
    _user = null;
    await userRepository.signOut();
  }

  Future<void> postComment(String postId, String text, String uid, String name, String profilePic) async {
    await userRepository.postComment(postId, text, uid, name, profilePic);
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return userRepository.getCommentsStream(postId);
  }
}

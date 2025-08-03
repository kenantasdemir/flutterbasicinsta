import "package:flutter/foundation.dart";
import "package:instagramcloneapp/locator.dart";
import "package:instagramcloneapp/services/firebase_firestore_service.dart";
import "../services/firebase_auth_service.dart";
import "package:instagramcloneapp/models/user.dart" as userModel;
import "package:instagramcloneapp/models/post.dart";
import "package:instagramcloneapp/models/comment.dart";

class UserRepository{

  var firebaseService = locator<FirebaseAuthService>();
  var firestoreService = locator<FirebaseFirestoreService>();

  Future<userModel.MyUser> signUpUser({required String email,required String password, required String username, required String bio,required Uint8List file})async{
     return await firebaseService.signUpUser(email: email, password: password, username: username, bio: bio, file: file);

  }

  Future<userModel.MyUser?> signInUser({required String email, required String password}) async {
    var cred = await firebaseService.signInUser(email: email, password: password);
    return await firestoreService.getUserByUid(cred.user!.uid);
  }

    Future<userModel.MyUser?> getCurrentUser()async{
      var currentUser = firebaseService.firebaseAuth.currentUser;
      return await firestoreService.getCurrentUser();
    }


  Future<bool> uploadPost(String uid, String profImage, String username, String text, Uint8List file) async{
      return await firestoreService.uploadPost(uid, username, profImage, text, file);
  }

  Future<void> followUser(String  id, String targetId) async{
   return await firestoreService.followUser(id,targetId);
  }

  Future<List<userModel.MyUser>> searchUsersByUsername(String username) async {
    return await firestoreService.searchUsersByUsername(username);
  }

  Future<List<Post>> getRecentPosts() async {
    return await firestoreService.getRecentPosts();
  }

  Future<List<Post>> getPostsByUid(String uid) async {
    return await firestoreService.getPostsByUid(uid);
  }

  Future<List<Post>> getPostsByIds(List ids) async {
    return await firestoreService.getPostsByIds(ids);
  }

  Future<List<Post>> getLikedPosts(String uid) async {
    return await firestoreService.getLikedPosts(uid);
  }

  Future<void> unfollowUser(String id, String targetId) async{
    await firestoreService.unfollowUser(id,targetId);
  }

  Future<void> signOut()async {
    await firebaseService.signOut();
  }

  Future<userModel.MyUser?> getUserByUid(String uid) async {
    return await firestoreService.getUserByUid(uid);
  }

  Future<void> savePost(String userId, String postId) async {
    await firestoreService.savePost(userId, postId);
  }

  Future<void> unsavePost(String userId, String postId) async {
    await firestoreService.unsavePost(userId, postId);
  }

  Future<void> postComment(String postId, String text, String uid, String name, String profilePic) async {
    await firestoreService.postComment(postId, text, uid, name, profilePic);
  }

  Stream<List<Comment>> getCommentsStream(String postId) {
    return firestoreService.getCommentsStream(postId);
  }
}
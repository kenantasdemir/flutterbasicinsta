import 'package:flutter/material.dart';
import 'package:instagramcloneapp/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../widgets/follow_button.dart';
import 'login_screen.dart';
import '../models/post.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userViewModel = Provider.of<UserViewModel>(context);
    final currentUser = userViewModel.getUser;
    final isOwnProfile = currentUser != null && currentUser.uid == widget.uid;

    return FutureBuilder(
        future: userViewModel.getUserByUid(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Kullanıcı bulunamadı',
                style: TextStyle(color: Colors.white70)));
          }
          final userData = snapshot.data!;
          final followers = userData.followers.length;
          final following = userData.following.length;
          final isFollowing = currentUser != null && userData.followers.contains(currentUser.uid);

          return Scaffold(
            backgroundColor: mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData.username.isNotEmpty ? userData.username : "Merhaba",
                style: const TextStyle(color: Colors.white),
              ),
              centerTitle: false,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userData.photoUrl.isNotEmpty
                                    ? userData.photoUrl
                                    : "https://plus.unsplash.com/premium_photo-1738597327926-cf2ed3945686?q=80&w=1443&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                              ),
                              radius: 40,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FutureBuilder<List<Post>>(
                                        future: userViewModel.getPostsByUid(
                                            widget.uid),
                                        builder: (context, postSnap) {
                                          int postLen = 0;
                                          if (postSnap.hasData) {
                                            postLen = postSnap.data!.length;
                                          }
                                          return buildStatColumn(
                                              postLen, "posts");
                                        },
                                      ),
                                      buildStatColumn(followers, "followers"),
                                      buildStatColumn(following, "following"),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FollowButton(
                                        text: 'Sign Out',
                                        backgroundColor: mobileBackgroundColor,
                                        textColor: Colors.white,
                                        borderColor: Colors.grey,
                                        function: () async {
                                          await Provider.of<UserViewModel>(
                                              context, listen: false).signOut();
                                          if (context.mounted) {
                                            Navigator
                                                .of(context)
                                                .pushReplacement(
                                              MaterialPageRoute(
                                                builder: (
                                                    context) => const LoginScreen(),
                                              ),
                                            );
                                          }
                                        },
                                      )

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            top: 15,
                          ),
                          child: Text(
                            userData.username.isNotEmpty ? userData.username : "kenant42",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            top: 1,
                          ),
                          child: Text(
                            userData.bio.isNotEmpty ? userData.bio : "My Bio",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: primaryColor,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          tabs: const [
                            Tab(icon: Icon(Icons.grid_on)),
                            Tab(icon: Icon(Icons.bookmark)),
                            Tab(icon: Icon(Icons.favorite)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Consumer<UserViewModel>(
                        builder: (context, userViewModel, _) {
                          return FutureBuilder<List<Post>>(
                            future: userViewModel.getPostsByUid(widget.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final posts = snapshot.data ?? [];
                              if (posts.isEmpty) {
                                return const Center(child: Text('Gönderi yok',
                                    style: TextStyle(color: Colors.white70)));
                              }
                              return GridView.builder(
                                shrinkWrap: true,
                                itemCount: posts.length,
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return SizedBox(
                                    child: Image(
                                      image: NetworkImage(post.postUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      Consumer<UserViewModel>(
                        builder: (context, userViewModel, _) {
                          final user = userViewModel.getUser;
                          final savedPosts = user?.savedPosts ?? [];
                          return FutureBuilder<List<Post>>(
                            future: savedPosts.isEmpty ? Future.value([]) : userViewModel.getPostsByIds(savedPosts),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final posts = snapshot.data ?? [];
                              if (posts.isEmpty) {
                                return const Center(child: Text('Kaydedilen gönderi yok', style: TextStyle(color: Colors.white70)));
                              }
                              return GridView.builder(
                                shrinkWrap: true,
                                itemCount: posts.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return SizedBox(
                                    child: Image(
                                      image: NetworkImage(post.postUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      Consumer<UserViewModel>(
                        builder: (context, userViewModel, _) {
                          final user = userViewModel.getUser;
                          final uid = user?.uid;
                          return FutureBuilder<List<Post>>(
                            future: (uid == null) ? Future.value([]) : userViewModel.getLikedPosts(uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Bir hata oluştu: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.redAccent),
                                  ),
                                );
                              }
                              final posts = snapshot.data ?? [];
                              if (posts.isEmpty) {
                                return const Center(child: Text('Beğenilen gönderi yok', style: TextStyle(color: Colors.white70)));
                              }
                              return GridView.builder(
                                shrinkWrap: true,
                                itemCount: posts.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 1.5,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return SizedBox(
                                    child: Image(
                                      image: NetworkImage(post.postUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

}
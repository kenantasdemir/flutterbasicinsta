import 'package:flutter/material.dart';
import 'package:instagramcloneapp/view_models/user_view_model.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../utils/colors.dart';
import '../widgets/follow_button.dart';

class PreviewProfileScreen extends StatefulWidget {
  final String uid;
  const PreviewProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<PreviewProfileScreen> createState() => _PreviewProfileScreenState();
}

class _PreviewProfileScreenState extends State<PreviewProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late MyUser? userData;
  bool isFollowing = false;
  int followers = 0;
  int following = 0;
  bool isLoading = true;
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _postsFuture =
        Provider.of<UserViewModel>(context, listen: false).getPostsByUid(widget.uid);
    fetchUser();
  }

  Future<void> fetchUser() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final user = await userViewModel.getUserByUid(widget.uid);
    final currentUser = userViewModel.getUser;
    setState(() {
      userData = user;
      followers = user!.followers.length;
      following = user.following.length;
      isFollowing = currentUser != null && user.followers.contains(currentUser.uid);
      isLoading = false;
    });
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

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData!.username ?? "Merhaba",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        userData!.photoUrl ??
                            "https://plus.unsplash.com/premium_photo-1738597327926-cf2ed3945686?q=80&w=1443&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                      ),
                      radius: 40,
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FutureBuilder<List<Post>>(
                                future: _postsFuture,
                                builder: (context, postSnap) {
                                  int postLen = 0;
                                  if (postSnap.hasData) {
                                    postLen = postSnap.data!.length;
                                  }
                                  return buildStatColumn(postLen, "posts");
                                },
                              ),
                              buildStatColumn(followers, "followers"),
                              buildStatColumn(following, "following"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              currentUser != null && currentUser.uid == widget.uid
                                  ? Container()
                                  : isFollowing
                                      ? FollowButton(
                                          text: 'Unfollow',
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          borderColor: Colors.grey,
                                          function: () async {
                                            await userViewModel.unfollowUser(currentUser!.uid, userData!.uid);
                                            setState(() {
                                              isFollowing = false;
                                              followers--;
                                            });
                                          },
                                        )
                                      : FollowButton(
                                          text: 'Follow',
                                          backgroundColor: Colors.blue,
                                          textColor: Colors.white,
                                          borderColor: Colors.blue,
                                          function: () async {
                                            await userViewModel.followUser(currentUser!.uid, userData!.uid);
                                            setState(() {
                                              isFollowing = true;
                                              followers++;
                                            });
                                          },
                                        ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(
                    userData!.username ?? "kenant42",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    userData!.bio ?? "My Bio",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.bookmark_border)),
              Tab(icon: Icon(Icons.favorite_border)),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<Post>>(
                  future: _postsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('Gönderi yok', style: TextStyle(color: Colors.white70)),
                      );
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
                ),
                Center(
                  child: Text(
                    'Kaydedilenler',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // 3. Tab: Favoriler
                Center(
                  child: Text(
                    'Favoriler',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

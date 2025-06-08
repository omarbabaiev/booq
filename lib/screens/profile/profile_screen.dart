import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user.dart';
import '../../routes/app_routes.dart';
import '../../widgets/post_card.dart';
import '../../models/post_with_user.dart';
import '../home/widgets/comment_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  late final ProfileController profileController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController(authController.user?.uid));
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        profileController.hasMorePosts.value &&
        !profileController.isLoadingPosts.value) {
      profileController.fetchUserPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              profileController.logout();
            },
          ),
        ],
      ),
      body: Obx(() {
        final appUser = profileController.userProfile.value;
        final authUser = authController.user;

        if (profileController.isLoadingProfile.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (appUser == null || authUser == null) {
          return const Center(child: Text('İstifadəçi məlumatları tapılmadı'));
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 280.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFB8B6F8), Color(0xFFF3F3FB)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage:
                              authUser.photoURL != null
                                  ? NetworkImage(authUser.photoURL!)
                                  : null,
                          backgroundColor: Colors.white,
                          child:
                              authUser.photoURL == null
                                  ? Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Color(0xFFB8B6F8),
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        appUser.name.isNotEmpty ? appUser.name : 'Anonim',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A3A5A),
                        ),
                      ),
                      Text(
                        appUser.username != null && appUser.username!.isNotEmpty
                            ? '@${appUser.username!}'
                            : 'Username yoxdur',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF7B7B93),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          appUser.bio ?? 'Bio yoxdur',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5A5A7A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Posts', appUser.postsCount),
                          _buildStatColumn('Followers', appUser.followersCount),
                          _buildStatColumn('Following', appUser.followingCount),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.toNamed(AppRoutes.editProfile);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB8B6F8),
                            side: const BorderSide(color: Color(0xFFB8B6F8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Profili Redaktə Et'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == profileController.userPosts.length) {
                    return Obx(
                      () => Center(
                        child:
                            profileController.isLoadingPosts.value &&
                                    profileController.hasMorePosts.value
                                ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                                : const SizedBox.shrink(),
                      ),
                    );
                  }
                  final postWithUser = profileController.userPosts[index];
                  return PostCard(
                    postWithUser: postWithUser,
                    onComment: () => _showComments(context, postWithUser),
                  );
                },
                childCount:
                    profileController.userPosts.length +
                    (profileController.hasMorePosts.value ? 1 : 0),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A3A5A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7B7B93)),
        ),
      ],
    );
  }

  void _showComments(BuildContext context, PostWithUser postWithUser) {
    Get.bottomSheet(
      CommentSheet(post: postWithUser.post, postUser: postWithUser.user),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

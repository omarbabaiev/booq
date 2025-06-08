import 'package:booq_last_attempt/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/feed_controller.dart';
import '../../controllers/comment_controller.dart';
import '../../models/post.dart';
import '../../widgets/post_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'widgets/comment_sheet.dart';
import '../../utils/date_utils.dart';
import '../../models/post_with_user.dart';
import '../../controllers/post_controller.dart';

class FeedView extends StatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final FeedController feedController = Get.find<FeedController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.put(PostController());
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
        feedController.hasMorePosts.value &&
        !feedController.isLoading.value) {
      feedController.fetchPosts();
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB8B6F8), Color(0xFFF3F3FB)],
        ),
      ),
      child: Obx(() {
        final isLoadingInitial =
            feedController.isLoading.value && feedController.posts.isEmpty;
        final isLoadingMore =
            feedController.isLoading.value && feedController.posts.isNotEmpty;

        return RefreshIndicator(
          onRefresh: feedController.refreshPosts,
          child: Skeletonizer(
            enabled: isLoadingInitial,
            child:
                isLoadingInitial
                    ? ListView.builder(
                      padding: EdgeInsets.only(top: 32, bottom: 32),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        // Dummy PostWithUser for skeletonizer
                        final dummyPostWithUser = PostWithUser(
                          post: Post(
                            id: '',
                            text: '',
                            createdAt: null,
                            likes: [],
                            commentsCount: 0,
                            reposts: 0,
                            userUid: '',
                            imageUrls: [],
                          ),
                          user: AppUser(
                            id: '',
                            name: '',
                            email: '',
                            photoUrl: '',
                            username: '',
                            bio: '',
                            followers: [],
                            following: [],
                            followRequests: [],
                          ),
                        );
                        return PostCard(
                          postWithUser:
                              dummyPostWithUser, // Pass dummy postWithUser
                        );
                      },
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: 32, bottom: 32),
                      itemCount:
                          feedController.posts.length +
                          (feedController.hasMorePosts.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == feedController.posts.length) {
                          return Obx(
                            () => Center(
                              child:
                                  feedController.isLoading.value &&
                                          feedController.hasMorePosts.value
                                      ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(),
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final postWithUser = feedController.posts[index];
                        return PostCard(
                          postWithUser:
                              postWithUser, // Pass postWithUser directly
                          onComment: () => _showComments(context, postWithUser),
                        );
                      },
                    ),
          ),
        );
      }),
    );
  }
}

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'auth_controller.dart';
import '../services/user_service.dart';
import '../models/post_with_user.dart';
import '../models/user.dart';

class FeedController extends GetxController {
  RxList<PostWithUser> posts = <PostWithUser>[].obs;
  final UserService _userService = UserService();
  final RxBool isLoading = true.obs;
  DocumentSnapshot? _lastDocument; // For pagination
  final int _postsPerPage = 10; // Number of posts to fetch per page
  final RxBool _isFetchingMore =
      false.obs; // To prevent multiple simultaneous fetches
  final RxBool hasMorePosts =
      true.obs; // To know if there are more posts to load

  @override
  void onInit() {
    super.onInit();
    fetchPosts(); // Call fetchPosts instead of direct listener
  }

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (_isFetchingMore.value && !isRefresh) return;

    if (isRefresh) {
      isLoading.value = true;
      _lastDocument = null; // Reset for refresh
      hasMorePosts.value = true; // Reset for refresh
      posts.clear(); // Clear existing posts for refresh
    } else if (!hasMorePosts.value) {
      return; // No more posts to fetch
    }

    _isFetchingMore.value = true;

    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_postsPerPage);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      final querySnapshot = await query.get();
      if (querySnapshot.docs.isEmpty) {
        hasMorePosts.value = false;
      } else {
        _lastDocument = querySnapshot.docs.last;
        final fetchedPosts =
            querySnapshot.docs
                .map(
                  (doc) =>
                      Post.fromMap(doc.data() as Map<String, dynamic>, doc.id),
                )
                .toList();

        List<PostWithUser> newPostsWithUsers = [];
        for (var post in fetchedPosts) {
          final user = await _userService.getUserById(post.userUid);
          Post? originalPost;
          AppUser? originalPostUser;

          if (post.repostedFromPostId != null) {
            originalPost = await PostService.getPostById(
              post.repostedFromPostId!,
            );
            if (originalPost != null) {
              originalPostUser = await _userService.getUserById(
                originalPost.userUid,
              );
            }
          }
          if (user != null) {
            newPostsWithUsers.add(
              PostWithUser(
                post: post,
                user: user,
                originalPost: originalPost,
                originalPostUser: originalPostUser,
              ),
            );
          } else {
            print(
              'User profile not found for post ${post.id} with userUid ${post.userUid}',
            );
          }
        }

        // Add only new posts to prevent duplicates
        final currentPostIds = posts.map((p) => p.post.id).toSet();
        for (var newPostWithUser in newPostsWithUsers) {
          if (!currentPostIds.contains(newPostWithUser.post.id)) {
            posts.add(newPostWithUser);
          }
        }
      }
    } catch (e) {
      print('Error fetching posts: $e');
      // Optionally show a snackbar or error message
    } finally {
      isLoading.value = false;
      _isFetchingMore.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await fetchPosts(isRefresh: true);
  }

  String? get currentUserId => Get.find<AuthController>().user?.uid;

  Future<void> likeOrUnlike(Post post) async {
    final userId = currentUserId;
    if (userId == null) return;

    final postWithUserIndex = posts.indexWhere(
      (item) => item.post.id == post.id,
    );
    if (postWithUserIndex == -1) return;

    final existingPost = posts[postWithUserIndex].post;
    final existingUser = posts[postWithUserIndex].user;

    List<String> updatedLikes = List.from(existingPost.likes);

    if (existingPost.likes.contains(userId)) {
      await PostService.unlikePost(post.id, userId);
      updatedLikes.remove(userId);
    } else {
      await PostService.likePost(post.id, userId);
      updatedLikes.add(userId);
    }

    // Update the specific post in the RxList
    posts[postWithUserIndex] = PostWithUser(
      post: Post(
        id: existingPost.id,
        text: existingPost.text,
        createdAt: existingPost.createdAt,
        likes: updatedLikes,
        commentsCount: existingPost.commentsCount,
        reposts: existingPost.reposts,
        userUid: existingPost.userUid,
        imageUrls: existingPost.imageUrls,
      ),
      user: existingUser,
    );
  }

  Future<void> repost(Post post) async {
    final user = Get.find<AuthController>().user;
    if (user == null) {
      Get.snackbar('Xəta', 'Repost etmək üçün daxil olmalısınız!');
      return;
    }

    final result = await PostService.repostPost(
      originalPostId: post.id,
      repostingUserUid: user.uid,
    );

    if (result == true) {
      Get.snackbar('Uğur', 'Paylaşım uğurla repost edildi!');
      await refreshPosts(); // Refresh the feed to show the new repost
    } else {
      Get.snackbar('Xəta', 'Repost zamanı xəta baş verdi!');
    }
  }

  Future<void> incrementComments(Post post) async {
    // This method is called by CommentController.
    await PostService.incrementComments(post.id);
  }

  Future<void> incrementCommentsById(String postId) async {
    await PostService.incrementComments(postId);
    final postWithUserIndex = posts.indexWhere(
      (item) => item.post.id == postId,
    );
    if (postWithUserIndex != -1) {
      final existingPost = posts[postWithUserIndex].post;
      final existingUser = posts[postWithUserIndex].user;
      final updatedPost = Post(
        id: existingPost.id,
        text: existingPost.text,
        createdAt: existingPost.createdAt,
        likes: existingPost.likes,
        commentsCount: existingPost.commentsCount + 1,
        reposts: existingPost.reposts,
        userUid: existingPost.userUid,
        imageUrls: existingPost.imageUrls,
      );
      posts[postWithUserIndex] = PostWithUser(
        post: updatedPost,
        user: existingUser,
      );
    }
  }
}

import 'package:get/get.dart';
import '../../services/user_service.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/post_service.dart';
import '../../models/post.dart';
import '../../models/post_with_user.dart';

class ProfileController extends GetxController {
  final UserService _userService = UserService();
  final AuthController _authController = Get.find<AuthController>();
  final String? userId;

  Rxn<AppUser> userProfile = Rxn<AppUser>();
  final RxBool isLoadingProfile = true.obs; // Renamed for clarity

  // For user's posts
  final RxList<PostWithUser> userPosts = <PostWithUser>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool hasMorePosts = true.obs;
  DocumentSnapshot? _lastDocument;
  final int _postsPerPage = 5;

  ProfileController(this.userId);

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchUserPosts(); // Fetch user-specific posts
  }

  Future<void> fetchUserProfile() async {
    if (userId != null) {
      _userService
          .getUserById(userId!)
          .then((user) {
            userProfile.value = user;
            isLoadingProfile.value = false;
          })
          .catchError((error) {
            print('Error fetching user profile: $error');
            isLoadingProfile.value = false;
            Get.snackbar('Xəta', 'Profil məlumatları yüklənmədi.');
          });
    } else {
      userProfile.value = null;
      isLoadingProfile.value = false;
    }
  }

  Future<void> fetchUserPosts() async {
    if (isLoadingPosts.value || !hasMorePosts.value || userId == null) {
      return;
    }

    isLoadingPosts.value = true;
    try {
      Query query = FirebaseFirestore.instance
          .collection('posts')
          .where('userUid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(_postsPerPage);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        hasMorePosts.value = false;
      } else {
        _lastDocument = querySnapshot.docs.last;
        final List<PostWithUser> fetchedPosts = [];
        for (var doc in querySnapshot.docs) {
          final post = Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          final postUser = await _userService.getUserById(post.userUid);
          if (postUser != null) {
            if (post.repostedFromPostId != null) {
              final originalPost = await PostService.getPostById(
                post.repostedFromPostId!,
              );
              if (originalPost != null) {
                final originalPostUser = await _userService.getUserById(
                  originalPost.userUid,
                );
                fetchedPosts.add(
                  PostWithUser(
                    post: post,
                    user: postUser,
                    originalPost: originalPost,
                    originalPostUser: originalPostUser,
                  ),
                );
              } else {
                // If original post not found, treat as a regular post for display
                fetchedPosts.add(PostWithUser(post: post, user: postUser));
              }
            } else {
              fetchedPosts.add(PostWithUser(post: post, user: postUser));
            }
          }
        }
        userPosts.addAll(
          fetchedPosts.where(
            (newPost) =>
                !userPosts.any(
                  (existingPost) => existingPost.post.id == newPost.post.id,
                ),
          ),
        );
        hasMorePosts.value = querySnapshot.docs.length == _postsPerPage;
      }
    } catch (e) {
      print('Error fetching user posts: $e');
      Get.snackbar('Xəta', 'Göndərilər yüklənərkən xəta baş verdi.');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> refreshUserPosts() async {
    _lastDocument = null;
    hasMorePosts.value = true;
    userPosts.clear();
    await fetchUserPosts();
  }

  // TODO: Edit Profile funksiyası
  void editProfile() {
    // Get.toNamed(AppRoutes.EDIT_PROFILE); // Yeni bir route olacaq
    print('Edit Profile tapped');
  }

  void logout() {
    Get.defaultDialog(
      title: 'Çıxış',
      middleText: 'Hesabından çıxmaq istədiyinə əminsənmi?',
      textConfirm: 'Bəli',
      textCancel: 'Xeyr',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back(); // Close the dialog
        await _authController.signOut(); // Perform logout
      },
      onCancel: () {
        // Do nothing, dialog closes automatically
      },
    );
  }

  @override
  void onClose() {
    // TODO: Close any streams if necessary
    super.onClose();
  }
}

import 'package:get/get.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import 'auth_controller.dart';
import 'feed_controller.dart';
import '../services/post_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';

class CommentController extends GetxController {
  final String postId;
  CommentController(this.postId);

  RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoading = false.obs;
  final RxString commentText = ''.obs;
  final TextEditingController textController = TextEditingController();
  final UserService _userService = UserService();

  @override
  void onInit() {
    super.onInit();
    CommentService.getComments(postId).listen((data) {
      comments.value = data;
    });
    textController.addListener(() {
      commentText.value = textController.text;
    });
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> addComment() async {
    if (commentText.value.trim().isEmpty) return;
    isLoading.value = true;
    final user = Get.find<AuthController>().user;
    if (user == null) {
      Get.snackbar('Xəta', 'Şərh yazmaq üçün daxil olmalısınız!');
      isLoading.value = false;
      return;
    }

    final currentUser = await _userService.getUserById(user.uid);
    if (currentUser == null) {
      Get.snackbar('Xəta', 'Kullanıcı bulunamadı.');
      isLoading.value = false;
      return;
    }

    final now = DateTime.now();
    DateTime lastCommentTimestamp =
        currentUser.lastCommentTimestamp ?? DateTime(2000);
    int commentsLastHourCount = currentUser.commentsLastHourCount;

    if (now.difference(lastCommentTimestamp).inHours >= 1) {
      commentsLastHourCount = 0;
    }

    if (commentsLastHourCount >= 5) {
      Get.snackbar('Xəta', 'Bir saat ərzində 5-dən çox şərh edə bilməzsiniz.');
      isLoading.value = false;
      return;
    }

    await CommentService.addComment(
      postId: postId,
      text: commentText.value.trim(),
      userName: user.displayName ?? '',
      userEmail: user.email ?? '',
      userPhotoUrl: user.photoURL ?? '',
    );

    await _userService.updateCommentCountAndTimestamp(user.uid);

    try {
      if (Get.isRegistered<FeedController>()) {
        await Get.find<FeedController>().incrementCommentsById(postId);
      }
    } catch (e) {
      print('Error adding comment notification: $e');
    }

    textController.clear();
    isLoading.value = false;
  }
}

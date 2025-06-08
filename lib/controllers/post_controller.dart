import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/post_service.dart';
import 'auth_controller.dart';
import '../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/feed_controller.dart';

class PostController extends GetxController {
  final textController = TextEditingController();
  final isLoading = false.obs;
  final RxList<File> selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        selectedImages.addAll(
          pickedFiles.map((xFile) => File(xFile.path)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Xəta', 'Şəkil seçilərkən xəta baş verdi: $e');
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> imageUrls = [];
    final storageRef = FirebaseStorage.instance.ref();
    final userUid = Get.find<AuthController>().user?.uid;
    if (userUid == null) return [];

    for (File imageFile in selectedImages) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final uploadTask = storageRef
            .child('post_images/$userUid/$fileName')
            .putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return imageUrls;
  }

  Future<void> _deleteImagesFromStorage(List<String> imageUrls) async {
    final storage = FirebaseStorage.instance;
    for (String url in imageUrls) {
      try {
        // Extract the path from the download URL
        // The path usually starts after the bucket name and 'o/' prefix
        final Uri uri = Uri.parse(url);
        // The path in Firebase Storage is usually everything after the /o/ in the URL
        // Example: https://firebasestorage.googleapis.com/v0/b/your-bucket.appspot.com/o/path%2Fto%2Fimage.jpg?alt=media...
        // We need 'path/to/image.jpg'
        String path = uri.pathSegments
            .sublist(uri.pathSegments.indexOf('o') + 1)
            .join('/');
        // Decode URL-encoded characters like %2F to /
        path = Uri.decodeComponent(path);

        await storage.ref(path).delete();
        print('Successfully deleted image: $url');
      } catch (e) {
        print('Error deleting image $url from Storage: $e');
      }
    }
  }

  Future<void> addPost() async {
    if (textController.text.trim().isEmpty && selectedImages.isEmpty) {
      Get.snackbar('Xəta', 'Paylaşmaq üçün mətn və ya şəkil əlavə edin!');
      return;
    }
    isLoading.value = true;
    final user = Get.find<AuthController>().user;
    if (user == null) {
      Get.snackbar('Xəta', 'Paylaşmaq üçün daxil olmalısınız!');
      isLoading.value = false;
      return;
    }

    List<String> uploadedImageUrls = [];
    if (selectedImages.isNotEmpty) {
      Get.snackbar(
        'Yüklənir',
        'Şəkillər yüklənir...',
        showProgressIndicator: true,
      );
      uploadedImageUrls = await uploadImages();
      Get.back();
      if (selectedImages.length != uploadedImageUrls.length) {
        Get.snackbar('Xəta', 'Şəkillərin bəziləri yüklənə bilmədi.');
        // If images failed to upload, we should also clear any partial uploads
        if (uploadedImageUrls.isNotEmpty) {
          await _deleteImagesFromStorage(uploadedImageUrls);
        }
        isLoading.value = false;
        return;
      }
    }

    final result = await PostService.addPost(
      text: textController.text.trim(),
      userUid: user.uid,
      imageUrls: uploadedImageUrls,
    );
    isLoading.value = false;
    if (result == true) {
      Get.snackbar('Uğur', 'Paylaşım uğurla göndərildi!');
      textController.clear();
      selectedImages.clear();
      // Refresh feed after successful post addition
      Get.find<FeedController>().refreshPosts();
    } else {
      // If post addition fails, delete the uploaded images from storage
      if (uploadedImageUrls.isNotEmpty) {
        await _deleteImagesFromStorage(uploadedImageUrls);
      }
      Get.snackbar('Xəta', 'Paylaşım zamanı xəta baş verdi!');
    }
  }

  Future<void> deletePost(
    String postId,
    String userUid,
    List<String> imageUrls,
  ) async {
    isLoading.value = true;
    try {
      await PostService.deletePost(postId, userUid, imageUrls);
      Get.snackbar('Uğur', 'Paylaşım uğurla silindi!');
      // Refresh feed after successful post deletion
      Get.find<FeedController>().refreshPosts();
    } catch (e) {
      Get.snackbar('Xəta', 'Paylaşım silinərkən xəta baş verdi: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

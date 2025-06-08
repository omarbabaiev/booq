import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSetupController extends GetxController {
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final isLoading = false.obs;
  final Rxn<File> _selectedImage = Rxn<File>();
  final photoUrl = ''.obs;

  File? get selectedImage => _selectedImage.value;

  final UserService _userService = UserService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();
    final user = Get.find<AuthController>().user;
    if (user != null && user.photoURL != null) {
      photoUrl.value = user.photoURL!;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage.value = File(pickedFile.path);
      photoUrl.value = '';
    }
  }

  Future<void> saveProfile() async {
    final username = usernameController.text.trim();
    final bio = bioController.text.trim();
    final user = Get.find<AuthController>().user;

    if (user == null) {
      Get.snackbar('Xəta', 'İstifadəçi tapılmadı!');
      return;
    }

    if (username.isEmpty) {
      Get.snackbar('Xəta', 'İstifadəçi adı boş ola bilməz!');
      return;
    }

    final usernameRegex = RegExp(r'^[a-z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(username)) {
      Get.snackbar('Xəta',
          'İstifadəçi adı 3-20 simvol olmalı və yalnız kiçik hərflər, rəqəmlər və alt xətdən ibarət olmalıdır!');
      return;
    }

    isLoading.value = true;

    final isUnique = await _userService.isUsernameUnique(username);
    if (!isUnique) {
      Get.snackbar('Xəta', 'Bu istifadəçi adı artıq mövcuddur!');
      isLoading.value = false;
      return;
    }

    String finalPhotoUrl = photoUrl.value;
    if (_selectedImage.value != null) {
      try {
        final uploadTask = _storage
            .ref('profile_images/${user.uid}')
            .putFile(_selectedImage.value!);
        final snapshot = await uploadTask.whenComplete(() => null);
        finalPhotoUrl = await snapshot.ref.getDownloadURL();
        Get.snackbar('Uğur', 'Profil şəkli yükləndi!');
      } catch (e) {
        Get.snackbar('Xəta', 'Profil şəkli yüklənmədi: ${e.toString()}');
        isLoading.value = false;
        return;
      }
    }

    await _userService.createOrUpdateUserProfile(
      userId: user.uid,
      name: user.displayName ?? username,
      email: user.email ?? '-',
      photoUrl: finalPhotoUrl,
      username: username,
      bio: bio,
    );

    isLoading.value = false;
    Get.snackbar('Uğur', 'Profil uğurla qeyd edildi!');
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

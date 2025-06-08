import 'package:get/get.dart';
import 'package:flutter/material.dart'; // For TextEditingController
import '../services/user_service.dart';
import '../models/user.dart'; // Import AppUser
import 'auth_controller.dart'; // To get current user ID
import 'package:image_picker/image_picker.dart'; // For image picking

class EditProfileController extends GetxController {
  final UserService _userService = UserService();
  final AuthController _authController = Get.find<AuthController>();

  final Rxn<AppUser> user = Rxn<AppUser>(); // User profile data
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final Rxn<String> pickedImagePath = Rxn<String>(); // Path of the picked image

  final RxBool isLoading = true.obs; // Loading state for fetching profile
  final RxBool isSaving = false.obs; // Loading state for saving profile
  final RxString usernameError = ''.obs; // Error message for username field

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final userId = _authController.user?.uid;
    if (userId == null) {
      isLoading.value = false;
      // Handle error: user not logged in
      return;
    }

    final fetchedUser = await _userService.getUserById(userId);
    if (fetchedUser != null) {
      user.value = fetchedUser;
      usernameController.text = fetchedUser.username ?? '';
      bioController.text = fetchedUser.bio ?? '';
    } else {
      // Handle error: user profile not found
    }
    isLoading.value = false;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImagePath.value = pickedFile.path;
    }
  }

  Future<void> saveProfile() async {
    final userId = _authController.user?.uid;
    if (userId == null) return; // User not logged in

    isSaving.value = true;
    usernameError.value = ''; // Clear previous errors

    final currentUsername =
        user.value?.username; // Current username from fetched profile
    final newUsername = usernameController.text.trim();

    // Validate username (not empty and matches regex - regex logic can be added later if needed)
    if (newUsername.isEmpty) {
      usernameError.value = 'İstifadəçi adı boş ola bilməz.';
      isSaving.value = false;
      return;
    }

    // Check username uniqueness only if changing and not the current username
    if (newUsername != currentUsername) {
      final isUnique = await _userService.isUsernameUnique(newUsername);
      if (!isUnique) {
        usernameError.value = 'Bu istifadəçi adı artıq istifadə olunur.';
        isSaving.value = false;
        return;
      }
    }

    // Check username change restriction (UserService will handle the 14-day logic)
    // We call updateUserProfile and let UserService handle the restriction check

    final result = await _userService.updateUserProfile(
      userId: userId,
      username: newUsername,
      bio: bioController.text.trim(),
      newPhotoPath: pickedImagePath.value, // Pass the picked image path
    );

    isSaving.value = false;

    if (result['success'] == true) {
      Get.snackbar('Uğur', result['message'] ?? 'Profil uğurla yeniləndi.');
      // Refresh user profile in controller after successful save
      fetchUserProfile(); // Or update the user Rxn directly
      // Consider navigating back after saving
      // Get.back();
    } else {
      Get.snackbar('Xəta',
          result['message'] ?? 'Profil yenilənməsi zamanı xəta baş verdi.');
      if (result['message'] != null &&
          result['message']!.contains('istifadəçi adınızı')) {
        usernameError.value = result['message']!;
      }
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }
}

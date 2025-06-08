import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoginMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _initialScreenRedirect);
  }

  void _initialScreenRedirect(User? user) async {
    if (user == null) {
      Get.offAllNamed(AppRoutes.auth);
    } else {
      final userExists = await _userService.checkUserExists(user.uid);
      if (userExists) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.profileSetup);
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      User? signedInUser = await _authService.signInWithGoogle();
      if (signedInUser != null) {
        Get.snackbar('Uğur', 'Google ilə daxil olundu!');
      } else {
        print(
            'Google giriş xətası: İstifadəçi girişdən imtina etdi və ya xəta baş verdi.');
      }
    } catch (e) {
      print('Google giriş xətası: $e');
      Get.snackbar('Google ilə giriş xətası', e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      Get.snackbar('Uğur', 'Hesabdan çıxış edildi.');
    } catch (e) {
      print('Çıxış xətası: $e');
      Get.snackbar('Çıxış xətası', e.toString());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

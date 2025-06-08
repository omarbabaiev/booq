import 'package:booq_last_attempt/main.dart';
import 'package:booq_last_attempt/screens/onboarding/onboarding_screen.dart';
import 'package:booq_last_attempt/screens/splash/splash_screen.dart';
import 'package:get/get.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/post/post_screen.dart';
import '../screens/qr/qr_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile_setup/profile_setup_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../../controllers/edit_profile_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingScreen()),
    GetPage(name: AppRoutes.auth, page: () => AuthScreen()),
    GetPage(name: AppRoutes.home, page: () => HomeScreen()),
    GetPage(name: AppRoutes.post, page: () => PostScreen()),
    GetPage(name: AppRoutes.qr, page: () => QRScreen()),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.profileSetup, page: () => ProfileSetupScreen()),
    GetPage(name: AppRoutes.notifications, page: () => NotificationsScreen()),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfileScreen(),
      binding: BindingsBuilder(() {
        Get.put(EditProfileController());
      }),
    ),
  ];
}

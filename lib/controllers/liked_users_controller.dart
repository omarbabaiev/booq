import 'package:get/get.dart';
import '../services/user_service.dart';
import '../models/user.dart'; // Import AppUser

class LikedUsersController extends GetxController {
  final UserService _userService = UserService();
  final RxList<AppUser> likedUsers = <AppUser>[].obs;
  final RxBool isLoading =
      false.obs; // Initially false, set to true when fetching

  Future<void> fetchLikedUsers(List<String> userIds) async {
    if (userIds.isEmpty) {
      likedUsers.clear();
      return;
    }
    isLoading.value = true;
    List<AppUser> fetchedUsers = [];
    for (String userId in userIds) {
      final user = await _userService.getUserById(userId);
      if (user != null) {
        fetchedUsers.add(user);
      }
    }
    likedUsers.value = fetchedUsers; // Update the observable list
    isLoading.value = false;
  }
}

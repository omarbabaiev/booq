import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/edit_profile_controller.dart'; // We will create this controller
import '../../models/user.dart'; // Import AppUser
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // Import dart:io for FileImage

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profili Redaktə Et'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB8B6F8),
              Color(0xFFF3F3FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            final user = controller.user.value; // Get user data from controller
            if (user == null) {
              return Center(child: Text('Kullanıcı bilgileri yüklenemedi.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: Obx(() {
                      final pickedImagePath = controller.pickedImagePath.value;
                      final photoUrl = user.photoUrl;
                      return CircleAvatar(
                        radius: 60,
                        backgroundImage: pickedImagePath != null
                            ? FileImage(File(
                                pickedImagePath)) // Use FileImage for picked image
                            : (photoUrl != null && photoUrl.isNotEmpty
                                ? NetworkImage(
                                    photoUrl) // Use NetworkImage for existing URL
                                : null), // Fallback to null if no image
                        backgroundColor: Colors.white,
                        child: (pickedImagePath == null &&
                                (photoUrl == null || photoUrl.isEmpty))
                            ? Icon(Icons.camera_alt,
                                size: 60, color: Color(0xFFB8B6F8))
                            : null,
                      );
                    }),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      border: OutlineInputBorder(),
                    ), // Add validator or logic for username restriction/uniqueness feedback here
                  ),
                  Obx(() => controller.usernameError.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            controller.usernameError.value,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                      : SizedBox.shrink()),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller.bioController,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isSaving.value
                            ? null
                            : () => controller.saveProfile(),
                        child: controller.isSaving.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Yadda Saxla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFB8B6F8),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      )),
                  // Display username change restriction info
                  Obx(() {
                    final lastChange =
                        controller.user.value?.lastUsernameChangeDate;
                    if (lastChange == null) return SizedBox.shrink();

                    final now = DateTime.now();
                    final nextChangeDate = lastChange.add(Duration(days: 14));
                    if (now.isBefore(nextChangeDate)) {
                      final remaining = nextChangeDate.difference(now).inDays +
                          1; // +1 to show full remaining days
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'İstifadəçi adınızı ${remaining} gün sonra yenidən dəyişə bilərsiniz.',
                          style: TextStyle(
                              color: Colors.orange[700], fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

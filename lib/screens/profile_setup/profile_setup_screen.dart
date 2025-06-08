import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_setup_controller.dart';

class ProfileSetupScreen extends StatelessWidget {
  final ProfileSetupController controller = Get.put(ProfileSetupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Quraşdırılması'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profil Şəkli (şimdilik Google-dan gələn)
              Obx(() => CircleAvatar(
                    radius: 60,
                    backgroundImage: controller.photoUrl.value.isNotEmpty
                        ? NetworkImage(controller.photoUrl.value)
                        : null,
                    child: controller.photoUrl.value.isEmpty
                        ? Icon(Icons.person, size: 60)
                        : null,
                  )),
              SizedBox(height: 24),
              // İstifadəçi Adı (Username)
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(
                  labelText: 'İstifadəçi Adı (Username)',
                  hintText: 'threads_stilinde_username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              // Bio
              TextField(
                controller: controller.bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Özün haqqında qısa məlumat',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32),
              // Saxla düyməsi
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.saveProfile(),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Profili Saxla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB8B6F8),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

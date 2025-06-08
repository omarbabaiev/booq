import 'package:booq_last_attempt/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_pages.dart';
import 'constants/app_strings.dart';
import 'controllers/auth_controller.dart';
import 'localization/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BooqApp());
}

class BooqApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: Locale('az'),
      fallbackLocale: Locale('en'),
      theme: ThemeData(textTheme: GoogleFonts.manropeTextTheme()),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    );
  }
}

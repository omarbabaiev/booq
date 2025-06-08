import 'package:intl/intl.dart';
import 'package:get/get.dart'; // For localization (.tr)
import 'package:timeago/timeago.dart' as timeago;

// Moved from post_card.dart
String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 9) {
    // If more than 9 days, show full date
    return DateFormat('dd.MM.yyyy').format(date);
  } else if (difference.inDays > 0) {
    // If more than 0 days but less than or equal to 9 days, show relative days
    return timeago.format(date, locale: Get.locale?.languageCode);
  } else if (difference.inHours > 0) {
    // If less than a day but more than 0 hours, show relative hours
    return timeago.format(date, locale: Get.locale?.languageCode);
  } else if (difference.inMinutes > 0) {
    // If less than an hour but more than 0 minutes, show relative minutes
    return timeago.format(date, locale: Get.locale?.languageCode);
  } else {
    // If less than a minute, show relative seconds or 'just now'
    return timeago.format(date, locale: Get.locale?.languageCode);
  }
}

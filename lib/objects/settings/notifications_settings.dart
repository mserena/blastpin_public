import 'package:blastpin/defines/globals.dart';

class CustomNotification{
  final CustomNotificationType type;
  final int time;
  final String text;

  CustomNotification({required this.type, required this.time, required this.text});

  factory CustomNotification.fromJson(Map<String, dynamic> data) {
    final CustomNotificationType type = getCustomNotificationTypeFromString(data['type'] as String);
    final int time = data['time'] as int;
    final String text = data['text'] as String;
    return CustomNotification(type: type, time: time, text: text);
  }
}

class CustomNotificationsSettings{
  final List<CustomNotification> notifications;

  CustomNotificationsSettings({required this.notifications});
  
  factory CustomNotificationsSettings.fromJson(Map<String, dynamic> data) {
    final List<dynamic> notificationsData = data['notifications'] as List<dynamic>;
    final List<CustomNotification> notifications = notificationsData.map((notificationData) => CustomNotification.fromJson(notificationData)).toList();
    return CustomNotificationsSettings(notifications: notifications);
  }
}
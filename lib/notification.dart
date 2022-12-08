import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> CreateNotification() async {
  var uniqueId = DateTime.now().microsecondsSinceEpoch.remainder(100000);
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: uniqueId,
      channelKey: 'basic_channel',
      title: '${Emojis.activites_tanabata_tree} Salar Dev',
      body: 'Welcome Salar Dev -- 2022',
      bigPicture: 'asset://assets/login_logo/login.png',
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );
}

Future<void> CreateScheduldNotification(String title, String body,
    DateTime time, String grpupkey, String largIcon) async {
  final int year = time.year;
  final int month = time.month;
  final int day = time.day;
  final int hour = time.hour;
  final int minute = time.minute;
  var uniqueId = DateTime.now().microsecondsSinceEpoch.remainder(100000);
  await AwesomeNotifications().createNotification(
    actionButtons: [
      NotificationActionButton(
        key: 'MARK_DONE',
        label: 'open',
      ),
    ],
    content: NotificationContent(
      id: uniqueId,
      channelKey: 'scheduld_channel',
      title: title,
      body: body,
      bigPicture: grpupkey,
      summary: largIcon,
      // bigPicture: 'asset://assets/login_logo/login.png',
      notificationLayout: NotificationLayout.Inbox,
      wakeUpScreen: true,
    ),
    schedule: NotificationCalendar(
      allowWhileIdle: true,
      repeats: true,
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: 0,
    ),
  );
}

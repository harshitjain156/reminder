import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotifyService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); //

  initializeNotification() async {
    _configureLocalTimezone();



    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("app_logo");

    final InitializationSettings initializationSettings =
        InitializationSettings(

      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    var details=await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if(details!.didNotificationLaunchApp==true){
        selectNotification(details.notificationResponse!.payload);
    }
    }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      if (kDebugMode) {
        print('notification payload: $payload');
      }
    } else {
      if (kDebugMode) {
        print("Notification Done");
      }
    }
    Get.to(() => Container(
          color: Colors.white,
        ));
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   //context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title),
    //     content: Text(body),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           await Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => SecondScreen(payload),
    //             ),
    //           );
    //         },
    //       )
    //     ],
    //   ),
    // );
    Get.dialog(const Text('Welcome to flutter'));
  }

  displayNotification({required String title, required String body}) async {
    if (kDebugMode) {
      print("doing test");
    }
    print(123);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'reminder', 'reminder',
        channelDescription: 'A new Flutter project.',
        importance: Importance.max,
        priority: Priority.high);
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        // iOS: iOSPlatformChannelSpecifics
    );
    print("object");
    await flutterLocalNotificationsPlugin.show(10, "title", "body", platformChannelSpecifics,payload: "00");

    // await flutterLocalNotificationsPlugin.show(
    //   10,
    //   title,
    //   body,
    //   platformChannelSpecifics,
    //   payload: 'Default_Sound',
    // );

  }
  void sendNotification({final id,final title,final body}){
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails("channelId", "channelName",icon: 'app_logo');
    NotificationDetails notificationDetails=NotificationDetails(android: androidNotificationDetails);
    flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
  }

  scheduledNotification() async {
    print("object");

    await flutterLocalNotificationsPlugin.zonedSchedule(
        30,
        'scheduled title',
        'theme changes 5 seconds ago',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'channelId', 'channelName',
                icon: "app_logo")),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }


  scheduledNotificationTime(int hour, int minutes,int year ,int month,int day,String title,String des) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      12,
      "${title}",
      "${des}",
      _convertTime(hour, minutes,year,month,day),
      //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
          android: AndroidNotificationDetails(
              'channelId', 'channelName',
              importance: Importance.max, priority: Priority.high,
              icon: 'app_logo')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      // payload: "${remind.title}|" + "${remind.dose}|"
    );

  }
  tz.TZDateTime _convertTime(int hour, int minutes,int year ,int month,int day){
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print(now);
    print(tz.local);
    tz.TZDateTime scheduleDate =
    tz.TZDateTime(tz.local, year, month, day, hour, minutes);

    if(scheduleDate.isBefore(now)){
      scheduleDate = scheduleDate.add(const Duration(days:1));
    }

    return scheduleDate;
  }
  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    final String timeZone  = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }
}

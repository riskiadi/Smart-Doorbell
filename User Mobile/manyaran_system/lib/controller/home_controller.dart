import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:manyaran_system/data/repository/firebase_database.dart';
import 'package:manyaran_system/utils/helper.dart';

class HomeController extends GetxController {

  final _firebaseDatabaseRepository = FirebaseDatabaseRepository().obs;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  late AndroidNotificationChannel channel;
  late StreamSubscription visitorSubscription;

  get firebaseDatabaseRepository => this._firebaseDatabaseRepository.value;
  set firebaseDatabaseRepository(value) {
    this._firebaseDatabaseRepository.value = value;
  }

  @override
  void onInit() async{

    _notificationChannelInit();
    _subscribeTopic();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_messageHandler);

    visitorSubscription = FirebaseDatabase.instance.reference().child('visitors').onChildChanged.listen((event) {
      print("DIUBAH");
    });
    visitorSubscription = FirebaseDatabase.instance.reference().child('visitors').onChildAdded.listen((event) {
      print("DITAMBAHKAN");
    });
    visitorSubscription = FirebaseDatabase.instance.reference().child('visitors').onChildRemoved.listen((event) {
      print("DIHAPUS");
    });

    firebaseRepository.getLastCamSnapshot();

    super.onInit();
  }

  @override
  void dispose() async {
    visitorSubscription.cancel();
    super.dispose();
  }

  _notificationChannelInit() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'manyaran_id',
        'Manyaran System',
        'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
        sound: RawResourceAndroidNotificationSound(
          'notification',
        ),
      );
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _messageHandler(initialMessage);
      }
    }
  }

  _subscribeTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('Doorbell');
  }

  _messageHandler(RemoteMessage message) async{
    Map<String, dynamic> messageData = message.data;
    if(Get.context!=null) showImageViewer(Get.context!, CachedNetworkImageProvider(messageData["image_url"]));
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background/terminated message");
    print(message.data);
  }

}
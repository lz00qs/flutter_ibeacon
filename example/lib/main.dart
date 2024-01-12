import 'package:flutter/material.dart';

import 'package:flutter_ibeacon_example/ibeacon_controller.dart';
import 'package:flutter_ibeacon_example/objectbox.dart';
import 'package:flutter_ibeacon_example/splash_page.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = IbeaconController();
  controller.objectBox = await ObjectBox.create();
  await controller.getIndex();
  Get.put(controller);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return const GetMaterialApp(
      debugShowCheckedModeBanner: true,
      // home: MainPage(),
      home: SplashPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:virtualmouseweb/Controllers/NodeControllers.dart';
import 'package:virtualmouseweb/Views/MainScreen.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'utils/Themes.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager
      .setPreventClose(true); // Prevents closing immediately, allowing cleanup

  windowManager.addListener(MyWindowListener()); // Add a listener
  await Window.initialize();
  await Window.setEffect(
      effect: WindowEffect.mica, color: Color.fromARGB(255, 99, 235, 106));
  Get.put(ConnectionController());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      title: 'Virtual Mouse',
      builder: EasyLoading.init(),
      home: MainScreen(),
    );
  }
}

class MyWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    print("Flutter Windows App is closing...");
    await performCleanup();
    windowManager.destroy(); // Allows closing after cleanup
  }
}

Future<void> performCleanup() async {
  print("Performing cleanup tasks...");
  stopNodeServer();
  // Add any cleanup logic here, like saving data, closing connections, etc.
}

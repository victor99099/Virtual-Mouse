import 'dart:io';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:process_run/process_run.dart';

class ServerOnStatusController extends GetxController {
  RxString isServerLoaded = 'false'.obs;

  Process? nodeProcess;
}

void startNodeServer(BuildContext context) async {
  try {
    print("Starting Server");
    EasyLoading.show();
    // Start the server process
    final controller = Get.find<ServerOnStatusController>();
    controller.nodeProcess = await Process.start('./server.exe', []);

    // Listen to the stdout and stderr streams
    controller.nodeProcess!.stdout.listen((data) {
      print('Node.js Output: ${String.fromCharCodes(data)}');
      if (String.fromCharCodes(data)
          .contains("Web app running at http://localhost:8080")) {
        Get.find<ServerOnStatusController>().isServerLoaded.value = 'true';
        EasyLoading.dismiss();
      } else if (String.fromCharCodes(data).contains("Mobile app connected")) {
        Get.find<ServerOnStatusController>().isServerLoaded.value = 'true';
        Get.find<ConnectionController>().isConnected.value = true;
        ElegantNotification.success(
          title: const Text(
            "Success",
            style: TextStyle(color: Colors.black),
          ),
          description: Text("Mobile app connected successfully",
              style: TextStyle(color: Colors.black)),
          onDismiss: () {
            // print('Message when the notification is dismissed');
          },
          onNotificationPressed: () {
            // print('Message when the notification is pressed');
          },
          isDismissable: true,
        ).show(context);
        EasyLoading.dismiss();
      } else if (String.fromCharCodes(data)
          .contains("Mobile app disconnected")) {
        Get.find<ConnectionController>().isConnected.value = false;
        ElegantNotification.error(
          title: const Text(
            "Error",
            style: TextStyle(color: Colors.black),
          ),
          description: Text("Mobile app disconnected",
              style: TextStyle(color: Colors.black)),
          onDismiss: () {
            // print('Message when the notification is dismissed');
          },
          onNotificationPressed: () {
            // print('Message when the notification is pressed');
          },
          isDismissable: true,
        ).show(context);
        EasyLoading.dismiss();
      }
    });

    controller.nodeProcess!.stderr.listen((data) async {
      print('Node.js Error: ${String.fromCharCodes(data)}');
      if (String.fromCharCodes(data)
          .contains("address already in use :::8080")) {
        // Print the output of the command
        var shell = Shell();
        try {
          // Run the PowerShell command
          await shell
              .run('powershell.exe Get-Process node | Stop-Process -Force');
        } catch (e) {
          print('Error: $e');
        }
        startNodeServer(context);
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
      }
    });
  } catch (e) {
    print("Failed to start Node.js: $e");
    Get.find<ServerOnStatusController>().isServerLoaded.value = 'failed';
    ElegantNotification.error(
      width: 360,
      position: Alignment.topRight,
      title: const Text('Error', style: TextStyle(color: Colors.black)),
      description: Text("Failed to start Node.js: $e", style: TextStyle(color: Colors.black)),
      onDismiss: () {},
    ).show(context);
    EasyLoading.dismiss();
  }
}

void stopNodeServer() {
  final controller = Get.find<ServerOnStatusController>();
  EasyLoading.show();
  if (controller.nodeProcess != null) {
    controller.nodeProcess!.kill(); // Kill the Node.js server process
    print("Node.js server stopped.");
    EasyLoading.dismiss();
  } else {
    print("Node.js server is not running.");
    EasyLoading.dismiss();
  }
}

class IpController extends GetxController {
  // Rxn for nullable string to hold IP address
  Rxn<String> IP = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    getIpAddress();
  }

  // Function to fetch IP address
  Future<void> getIpAddress() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP();
    if (ip != null) {
      IP.value = ip;
      print("Ip $ip");
    } else {
      IP.value = null;
    }
  }
}

class ConnectionController extends GetxController {
  RxBool isConnected = false.obs;
}

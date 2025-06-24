import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../MainScreen/MainScreen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final List<TextEditingController> ipControllers =
      List.generate(4, (_) => TextEditingController());
  WebSocketChannel? channel;
  final MobileScannerController controller = MobileScannerController();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    controller.start();
    // controller.detectionSpeed = ;
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) async {
    final String code = barcodeCapture.barcodes.first.rawValue ?? '---';
    print("QR Code Detected: $code");
    // InterstitialAdManager interstitialAdManager = InterstitialAdManager();
    // interstitialAdManager.loadAd();

    // If connection is already attempted, return early
    if (isConnected) return;

    // Show loading indicator

    try {
      EasyLoading.show();
      // Attempt to connect to the WebSocket
      channel = WebSocketChannel.connect(Uri.parse(code));

      Get.off(() => MainControlScreen(channel: channel!));
      setState(() {
        isConnected = true; // Mark connection as successful
      });
      // Future.delayed(Duration(seconds: 2), () {
      //   // interstitialAdManager.showAd(() {
      //   //   print("Proceeding after ad...");
      //   //   // Proceed with app functionality after ad is closed
      //   // });
      // });
    } catch (e) {
      Get.snackbar("Error", "Invalid QR code or connection failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  bool isThrottled = false;

  void _connectManually() async {
    if (isThrottled) return;
    isThrottled = true;
    Future.delayed(Duration(seconds: 2), () {
      isThrottled = false;
    });
    String ipAddress = ipControllers.map((c) => c.text).join('.').trim();
    print(ipAddress);
    for (int i = 0; i < ipControllers.length; i++) {
      if (ipControllers[i].text.isEmpty) {
        Get.snackbar("Error", "Please fill all IP address fields");
        return;
      }
    }

    try {
      EasyLoading.show();
      channel = WebSocketChannel.connect(Uri.parse("ws://$ipAddress:8080"));
      channel!.stream.listen(
        (message) {
          print("Connection successful: $message");
          setState(() {
            isConnected = true;
          });
          Get.off(() => MainControlScreen(channel: channel!));
        },
      );
      Future.delayed(Duration(milliseconds: 1200), () {
        if (isConnected == false) {
          Get.snackbar("Error", "Invalid IP address or connection failed");
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Invalid IP address or connection failed");
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: currentTheme.primaryColor),
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          title: Text(
            'Scan or Enter IP Manually',
            style: TextStyle(
                fontSize: 20,
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.bold),
          )),
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Column(
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                height: Get.height,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: _onDetect,
                    ),
                    Positioned(
                        top: Get.width * 0.4,
                        left: Get.width * 0.2,
                        child: Container(
                          width: Get.width * 0.6,
                          height: Get.height * 0.3,
                          decoration: BoxDecoration(
                              // boxShadow: [
                              //   BoxShadow(
                              //       color: currentTheme.primaryColor,
                              //       blurRadius: 10),
                              // ],
                              color: Colors.transparent,
                              border: Border.all(
                                  color: currentTheme.primaryColor, width: 3),
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle),
                        ))
                  ],
                ),
              ),
            ),
            SizedBox(
              width: Get.width,
              height: Get.height * 0.1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      useSafeArea: true,
                      // barrierColor: currentTheme.primaryColor,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 1,
                        // minChildSize: 0.7,
                        // maxChildSize: 0.7,
                        builder: (context, scrollController) => Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter IP",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: currentTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("Enter IP address shown on desktop app:"),
                              SizedBox(height: 16),
                              Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: Get.width * 0.01,
                                  runSpacing: Get.height * 0.01,
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: SizedBox(
                                        width: Get.width * 0.25,
                                        child: TextField(
                                          controller: ipControllers[0],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                    color: currentTheme
                                                        .primaryColor,
                                                    width: 2)),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            hintText: "0-255",
                                          ),
                                          textAlign: TextAlign.center,
                                          // maxLength: 3,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ".",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: SizedBox(
                                        width: Get.width * 0.25,
                                        child: TextField(
                                          controller: ipControllers[1],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                    color: currentTheme
                                                        .primaryColor,
                                                    width: 2)),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            hintText: "0-255",
                                          ),
                                          textAlign: TextAlign.center,
                                          // maxLength: 3,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ".",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: SizedBox(
                                        width: Get.width * 0.25,
                                        child: TextField(
                                          controller: ipControllers[2],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                    color: currentTheme
                                                        .primaryColor,
                                                    width: 2)),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            hintText: "0-255",
                                          ),
                                          textAlign: TextAlign.center,
                                          // maxLength: 3,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ".",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: SizedBox(
                                        width: Get.width * 0.25,
                                        child: TextField(
                                          controller: ipControllers[3],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide(
                                                    color: currentTheme
                                                        .primaryColor,
                                                    width: 2)),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            hintText: "0-255",
                                          ),
                                          textAlign: TextAlign.center,
                                          // maxLength: 3,
                                        ),
                                      ),
                                    ),
                                  ]),
                              SizedBox(height: 16),
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        currentTheme.cardColor),
                                    elevation: WidgetStatePropertyAll(4),
                                    shadowColor: WidgetStatePropertyAll(
                                        currentTheme.primaryColor),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            side: BorderSide(
                                                color:
                                                    currentTheme.primaryColor,
                                                width: 2)))),
                                onPressed: () {
                                  _connectManually();
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      "Connect",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: currentTheme.primaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(currentTheme.cardColor),
                      elevation: WidgetStatePropertyAll(4),
                      // shadowColor:
                      //     WidgetStatePropertyAll(currentTheme.primaryColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: currentTheme.primaryColor, width: 1)))),
                  child: Text(
                    "Or Enter Ip Address",
                    style: TextStyle(
                      fontSize: 16,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

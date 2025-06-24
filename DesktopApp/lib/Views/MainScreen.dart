import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import '../Controllers/NodeControllers.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  // Instantiate the IpController
  final IpController ipController = Get.put(IpController());
  final ServerOnStatusController serverOnStatusController =
      Get.put(ServerOnStatusController());

  @override
  void initState() {
    super.initState();
    startNodeServer(context);
  }

  @override
  void dispose() {
    stopNodeServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RxBool isTapped = false.obs;
    RxDouble width = (MediaQuery.of(context).size.width).obs;
    RxDouble height = (MediaQuery.of(context).size.height).obs;
    final currentTheme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: currentTheme.canvasColor,
      body: Column(
        children: [
          Header(currentTheme: currentTheme, height: height, width: width),
          Obx(() {
            if (ipController.IP.value == null ||
                serverOnStatusController.isServerLoaded.value == 'false' ||
                serverOnStatusController.isServerLoaded.value == 'failed') {
              return LoadingAndFailed(
                  ipController: ipController,
                  serverOnStatusController: serverOnStatusController,
                  isTapped: isTapped,
                  width: width,
                  height: height,
                  currentTheme: currentTheme);
            } else if (serverOnStatusController.isServerLoaded.value ==
                    'true' &&
                Get.find<ConnectionController>().isConnected.value == false) {
              return ScanBox(
                  currentTheme: currentTheme,
                  height: height,
                  width: width,
                  ipController: ipController);
            } else if (Get.find<ConnectionController>().isConnected.value ==
                true) {
              return ConnectedScreen(
                currentTheme: currentTheme,
                height: height,
                width: width,
              );
            } else {
              return SizedBox();
            }
          }),
        ],
      ),
    );

    // Check if IP is null and display appropriate UI
    // if (ipController.IP.value == null && ) {
    //   return
  }
}

class ConnectedScreen extends StatelessWidget {
  const ConnectedScreen(
      {super.key,
      required this.currentTheme,
      required this.height,
      required this.width});

  final ThemeData currentTheme;
  final RxDouble height;
  final RxDouble width;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Modes Description",
                    style: TextStyle(
                        // textBaseline: 40,
                        fontSize: (width.value + height.value) * 0.02,
                        color: currentTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: currentTheme.primaryColor, blurRadius: 10),
                        ],
                        color: currentTheme.cardColor,
                        border: Border.all(color: currentTheme.primaryColor),
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle),
                    child: Padding(
                      padding:
                          EdgeInsets.all((width.value + height.value) * 0.01),
                      child: Text(
                        "🟢 Your mobile is connected",
                        style: TextStyle(
                          fontSize: (width.value + height.value) * 0.01,
                          color: currentTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height.value * 0.05,
              ),
              Text(
                "Below are the available control modes you can use to interact with your desktop.",
                style: TextStyle(
                  fontSize: (width.value + height.value) * 0.01,
                  color: currentTheme.primaryColor,
                ),
              ),
              SizedBox(
                height: height.value * 0.04,
              ),
              ModeBox(
                width: width,
                height: height,
                isPadded: false,
                desc:
                    "Transform your phone into a fully functional touchpad, similar to a laptop’s trackpad. Use gestures such as tap to click, two-finger scrolling, and multi-touch gestures for an intuitive experience.",
                img: "assets/TouchpadLogo.png",
                name: "Touchpad Mode",
              ),
              SizedBox(
                height: height.value * 0.03,
              ),
              ModeBox(
                width: width,
                height: height,
                isPadded: true,
                desc:
                    "Use your phone like a gaming controller in landscape mode. This mode features an on-screen joystick, virtual keyboard, and dedicated mouse buttons, allowing seamless control for gaming and navigation.",
                img: "assets/JoystickLogo.png",
                name: "Joystick Mode",
              ),
              SizedBox(
                height: height.value * 0.03,
              ),
              ModeBox(
                width: width,
                height: height,
                isPadded: true,
                desc:
                    "Leverage your phone's gyroscope to control the cursor by pointing your device at the screen. This allows for precise and natural movement, similar to an air mouse, making it ideal for presentations and interactive tasks.",
                img: "assets/PointerLogo.png",
                name: "Pointer Mode",
              ),
              SizedBox(
                height: height.value * 0.03,
              ),
              ModeBox(
                width: width,
                height: height,
                isPadded: true,
                desc:
                    "Enhance your presentations with powerful features. Navigate slides, start and end presentations, and even annotate slides using different colors. The undo and redo options provide flexibility while drawing on the screen, making it perfect for professional use.",
                img: "assets/PresentationLogo.png",
                name: "Presentation Mode",
              ),
              SizedBox(
                height: height.value * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanBox extends StatelessWidget {
  const ScanBox({
    super.key,
    required this.width,
    required this.currentTheme,
    required this.height,
    required this.ipController,
  });
  final RxDouble width;
  final ThemeData currentTheme;
  final RxDouble height;
  final IpController ipController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: currentTheme.primaryColor, blurRadius: 10),
                  ],
                  color: currentTheme.cardColor,
                  border: Border.all(color: currentTheme.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle),
              width: height.value * 0.7,
              height: height.value * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    foregroundColor: currentTheme.primaryColor,
                    data:
                        'ws://${ipController.IP.value}:8080/', // Use the IP from GetX
                    version: QrVersions.auto,
                    size: height.value * 0.3,
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: Size(width.value * 0.5, Get.height * 0.3),
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Scan on our mobile app to Connect',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your IP : ${ipController.IP.value}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: currentTheme.primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          width: Get.width * 0.026,
                          height: Get.height *0.05,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: currentTheme.primaryColor,
                                    blurRadius: 5),
                              ],
                              color: currentTheme.cardColor,
                              shape: BoxShape.circle),
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                ipController.getIpAddress();
                              },
                              splashColor: currentTheme.primaryColor,
                              splashRadius: 10,
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    currentTheme.canvasColor),
                              ),
                              icon: Icon(
                                size: Get.width* 0.015,
                                Icons.refresh_outlined,
                                color: currentTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoadingAndFailed extends StatelessWidget {
  const LoadingAndFailed({
    super.key,
    required this.ipController,
    required this.serverOnStatusController,
    required this.isTapped,
    required this.width,
    required this.height,
    required this.currentTheme,
  });

  final IpController ipController;
  final ServerOnStatusController serverOnStatusController;
  final RxBool isTapped;
  final RxDouble width;
  final RxDouble height;
  final ThemeData currentTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ipController.IP.value == null
                ? Column(
                    children: [
                      Icon(
                        Icons.wifi_off,
                        color: Colors.red,
                        size: 80,
                      ),
                      Text(
                        'Failed to fetch IP. Please make sure you are connected to WiFi.',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : serverOnStatusController.isServerLoaded.value == 'failed'
                    ? Column(
                        spacing: 30,
                        children: [
                          Text(
                            'Failed to load node server, Please restart the app.',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          GestureDetector(
                            onTapDown: (details) {
                              isTapped.value = true;
                            },
                            onTapUp: (details) {
                              isTapped.value = false;
                            },
                            onTap: () {
                              stopNodeServer();
                              // Logic to refresh or restart the server can go here
                              startNodeServer(context);
                              ipController.getIpAddress();
                            },
                            child: Obx(
                              () => Container(
                                width: width.value * 0.394,
                                height: height.value * 0.1,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      isTapped.value
                                          ? BoxShadow(
                                              color: currentTheme.primaryColor,
                                              blurRadius: 0)
                                          : BoxShadow(
                                              color: currentTheme.primaryColor,
                                              blurRadius: 5,
                                              // offset: Offset(-4, 4),
                                            ),
                                    ],
                                    color: currentTheme.cardColor,
                                    border: Border.all(
                                        color: currentTheme.primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                    shape: BoxShape.rectangle),
                                child: Center(
                                  child: Text(
                                    "Retry Loading Server",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: isTapped.value
                                            ? currentTheme.primaryColor
                                            : Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        spacing: 30,
                        children: [
                          SizedBox(
                            width: height.value * 0.25,
                            height: height.value * 0.25,
                            child: CircularProgressIndicator(
                              strokeWidth: 5,
                              color: currentTheme.primaryColor,
                            ),
                          ),
                          Text(
                            'Loading node server, Please wait ....',
                            style: TextStyle(
                                fontSize: 18, color: currentTheme.primaryColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.currentTheme,
    required this.height,
    required this.width,
  });

  final ThemeData currentTheme;
  final RxDouble height;
  final RxDouble width;

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: currentTheme.primaryColor,
      elevation: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(color: currentTheme.primaryColor)),
        ),
        height: height.value * 0.2,
        width: width.value,
        child: Padding(
          padding: EdgeInsets.only(
              top: height.value * 0.025,
              right: 16.0,
              bottom: height.value * 0.025),
          child: Row(
            spacing: width.value * 0.01,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: Image.asset(
                  "assets/mouseIcon.png",
                  fit: BoxFit.contain,
                  // width: width.value * 0.08,
                  // height: height.value * 0.2,
                ),
              ),
              Text(
                'Virtual Mouse',
                style: TextStyle(
                    fontSize: 40,
                    color: currentTheme.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeBox extends StatefulWidget {
  final String name;
  final String desc;
  final String img;
  final bool isPadded;
  final RxDouble height;
  final RxDouble width;
  const ModeBox(
      {super.key,
      required this.isPadded,
      required this.width,
      required this.height,
      required this.desc,
      required this.img,
      required this.name});

  @override
  State<ModeBox> createState() => _ModeBoxState();
}

class _ModeBoxState extends State<ModeBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Container(
      width: Get.width,
      height: Get.height * 0.3,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: currentTheme.primaryColor, blurRadius: 10),
          ],
          color: currentTheme.cardColor,
          border: Border.all(color: currentTheme.primaryColor),
          borderRadius: BorderRadius.circular(10),
          shape: BoxShape.rectangle),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return RadialGradient(
                    center: Alignment.center,
                    radius: 0 + (_controller.value * 1),
                    colors: [
                      currentTheme.primaryColor,
                      currentTheme.primaryColor.withOpacity(0.6),
                      currentTheme.primaryColorLight,
                    ],
                    stops: [0.0, 0.8, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Image.asset(
                  widget.img,
                  width: Get.width * 0.22,
                  height:
                      widget.isPadded ? Get.height * 0.21 : Get.height * 0.25,
                ),
              );
            },
          ),
          SizedBox(
            width: Get.width * 0.62,
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                      fontSize:
                          (widget.width.value + widget.height.value) * 0.015,
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.desc,
                  softWrap: true,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: (widget.width.value + widget.height.value) * 0.008,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

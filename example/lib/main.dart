import 'package:brain_dev_firebase_login/config/routes/route_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:brain_dev_firebase_login/brain_dev_firebase_login.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:brain_dev_tools/tools/constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _brainDevFirebaseLoginPlugin = BrainDevFirebaseLogin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _brainDevFirebaseLoginPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: [
            MyElevatedButton(
                onPressed: (){
                  RouteHelperAuth.navLoginPage();
                },
                child: Text('navLoginPage')
            ),
            MyElevatedButton(
                onPressed: (){
                  RouteHelperAuth.navigateLoginPage();
                },
                child: Text('navigate LoginPage')
            ),
            MyElevatedButton(
                onPressed: (){
                  RouteHelperAuth.navigateToInformationScreen(Constant.privacy_policy);
                },
                child: Text('navigateTo InformationScreen')
            ),
            MyElevatedButton(
                onPressed: (){
                  RouteHelperAuth.navProfileScreen(userId: '');
                },
                child: Text('navProfileScreen')
            ),

            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
          ],
        ),
      ),
    );
  }
}

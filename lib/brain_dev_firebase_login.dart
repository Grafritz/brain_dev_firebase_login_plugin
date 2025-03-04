
import 'brain_dev_firebase_login_platform_interface.dart';

import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_tools/config/app_config.dart';
import 'package:brain_dev_tools/tools/tools_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'package:brain_dev_firebase_login/config/dependencies_tools.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

initBrainDevFirebaseLogin({ bool initializeApp= true }) async {

  if( initializeApp ) {
    try {
      FirebaseOptions? firebaseOptions = EnvironmentVariable.firebaseOptions;
      await Firebase.initializeApp(options: firebaseOptions);
      //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (ex, trace) {
      logError(ex, trace: trace, position: 'FirebaseLogin::initFirebaseLogin:001');
    }
  }

  try {
    initBrainDevFireBaseLoginDependencies();
    await Get.find<FirebaseAuthController>().initFirebaseAuth();
  } catch (ex, trace) {
    logError(ex, trace: trace, position: 'FirebaseLogin::initFirebaseLogin:002');
  }
}
class BrainDevFirebaseLogin {
  Future<String?> getPlatformVersion() {
    return BrainDevFirebaseLoginPlatform.instance.getPlatformVersion();
  }
}

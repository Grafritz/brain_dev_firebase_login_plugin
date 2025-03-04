import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'brain_dev_firebase_login_platform_interface.dart';

/// An implementation of [BrainDevFirebaseLoginPlatform] that uses method channels.
class MethodChannelBrainDevFirebaseLogin extends BrainDevFirebaseLoginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('brain_dev_firebase_login');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

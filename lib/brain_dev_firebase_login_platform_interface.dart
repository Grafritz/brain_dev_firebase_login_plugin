import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'brain_dev_firebase_login_method_channel.dart';

abstract class BrainDevFirebaseLoginPlatform extends PlatformInterface {
  /// Constructs a BrainDevFirebaseLoginPlatform.
  BrainDevFirebaseLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BrainDevFirebaseLoginPlatform _instance = MethodChannelBrainDevFirebaseLogin();

  /// The default instance of [BrainDevFirebaseLoginPlatform] to use.
  ///
  /// Defaults to [MethodChannelBrainDevFirebaseLogin].
  static BrainDevFirebaseLoginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BrainDevFirebaseLoginPlatform] when
  /// they register themselves.
  static set instance(BrainDevFirebaseLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:brain_dev_firebase_login/brain_dev_firebase_login.dart';
import 'package:brain_dev_firebase_login/brain_dev_firebase_login_platform_interface.dart';
import 'package:brain_dev_firebase_login/brain_dev_firebase_login_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBrainDevFirebaseLoginPlatform
    with MockPlatformInterfaceMixin
    implements BrainDevFirebaseLoginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BrainDevFirebaseLoginPlatform initialPlatform = BrainDevFirebaseLoginPlatform.instance;

  test('$MethodChannelBrainDevFirebaseLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBrainDevFirebaseLogin>());
  });

  test('getPlatformVersion', () async {
    BrainDevFirebaseLogin brainDevFirebaseLoginPlugin = BrainDevFirebaseLogin();
    MockBrainDevFirebaseLoginPlatform fakePlatform = MockBrainDevFirebaseLoginPlatform();
    BrainDevFirebaseLoginPlatform.instance = fakePlatform;

    expect(await brainDevFirebaseLoginPlugin.getPlatformVersion(), '42');
  });
}

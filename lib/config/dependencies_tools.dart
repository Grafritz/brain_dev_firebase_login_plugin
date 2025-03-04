import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_tools/tools/tools_log.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

initBrainDevFireBaseLoginDependencies() async
{
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  final BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;

  //Get.lazyPut(() => AutoScrollController);
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => deviceInfo);
  String uniqueId = '';
  try {
    uniqueId = const Uuid().v1();
    logCat('FirebaseLogin:: uniqueId: $uniqueId');
  } catch (ex, trace) {
    logError(ex, trace: trace, position: 'Uuid');
  }

  Get.lazyPut(() => uniqueId);
//endregion

  //region Repository
  //Get.lazyPut(() => NotificationRepository(flutterLocalNotificationsPlugin: Get.find()), fenix: true);
  // Get.lazyPut(() => UserRepository(apiClient: Get.find(), sharedPreferences: Get.find(), firebaseMessaging: Get.find()), fenix: true);
  //endregion

  //region Controller
  Get.lazyPut(() => FirebaseAuthController(
      senderFirebaseMessageService: Get.find(),
      sharedPreferences: Get.find(),
      userRepository: Get.find()), fenix: true);
  //Get.put<UserService>(FirebaseUserService(userController: Get.find<UserController>()));

  //endregion

  //region Model
  //endregion
}


import 'package:brain_dev_tools/config/app_config.dart';

class ApiConstantToDelete
{
  // pagination settings
  // the number of recipes to load per page
  static const perPage = 10;

  static String get urlServerImageNotification => '$urlApiServer/image/notification';

  static String get urlWebServer {
    return EnvironmentVariable.urlWebServer;
  }
  static String get urlApiServer {
    return EnvironmentVariable.urlApiServer;
  }

  //region [ Urls settings ]
  //static String urlApiSettings = '$urlApiServer${EnvironmentVariable.endPointApi.settings}';
  //endregion

  //region [ Urls User ]
  // static String urlApiDeviceToken = '$urlApiServer${EnvironmentVariable.endPointApi.deviceToken}';
  // static String apiUrlSetDeviceToken = '$urlApiServer${EnvironmentVariable.endPointApi.setDeviceToken}';
  // static String apiUrlRefreshDeviceToken = '$urlApiServer${EnvironmentVariable.endPointApi.refreshDeviceToken}';
  //endregion

  //region [ Urls User ]
  // static String urlApiUser = '$urlApiServer${EnvironmentVariable.endPointApi.user}';
  // static String urlApiAutoAuthenticate = '$urlApiServer${EnvironmentVariable.endPointApi.autoAuthenticate}';
  // static String urlApiLoginRegisterProvider = '$urlApiServer${EnvironmentVariable.endPointApi.login}';
  // static String urlApiRegister = '$urlApiServer${EnvironmentVariable.endPointApi.register}';

  // static String urlApiUserByUserName({userName}) => '$urlApiUser/$userName';
  // static String urlApiGetProfilUserData({userName}) => '$urlApiUser/profile-info/$userName';
  // static String urlApiGetProfilPublicUserData({userName}) => '$urlApiUser/profile-public-info/$userName';
  // static String urlApiUpdateProfile = '$urlApiUser/update-profile';
  // static String urlApiUpdatePhotoProfile = '$urlApiUser/update-photo-profile';

  // static String urlApiDeleteAllDataUser = '$urlApiUser/deletealldata';

  //endregion

}
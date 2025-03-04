
import 'package:brain_dev_business/config/routes/route_name.dart';
// import 'package:brain_dev_firebase_login/config/routes/route_name.dart';
import 'package:brain_dev_firebase_login/security/login_page.dart';
import 'package:brain_dev_firebase_login/security/profile_edit_screen.dart';
import 'package:brain_dev_firebase_login/security/recovery_password_page.dart';
import 'package:brain_dev_firebase_login/security/register_page.dart';
import 'package:brain_dev_firebase_login/views/information-screen/information_screen.dart';
import 'package:get/get.dart';

class RoutesAuth
{
  //region [ NAVIGATOR PAGES ]
  static List<GetPage> routes = [
    GetPage(name: RouteNameBusiness.routeLogin, page: () => LoginPage(redirect: Get.parameters[RouteNameBusiness.redirectVar] )),
    GetPage(name: RouteNameBusiness.routeLoginWeb, page: () => LoginPage(redirect: Get.parameters[RouteNameBusiness.redirectVar] )),
    GetPage(name: RouteNameBusiness.registerPage, page: () =>  RegisterPage(redirect: Get.parameters[RouteNameBusiness.redirectVar] )),
    GetPage(name: RouteNameBusiness.recoveryPasswordPage, page: () => RecoveryPasswordPage(redirect: Get.parameters[RouteNameBusiness.redirectVar] )),
    //GetPage(name: profilePage, page: () =>  const ProfilePage()),
    GetPage(name: RouteNameBusiness.profilePage, page: () =>  const EditProfileScreen()),
    GetPage(name: RouteNameBusiness.editProfilePage, page: () =>  const EditProfileScreen()),
    GetPage(name: RouteNameBusiness.informationScreen, page: () => InformationScreen(information: Get.parameters[RouteNameBusiness.pageVar])),
  ];
//endregion
}

// ignore_for_file: constant_identifier_names
import 'package:brain_dev_business/config/routes/route_helper_business_auth.dart';
import 'package:brain_dev_business/config/routes/route_name.dart';
import 'package:brain_dev_firebase_login/security/login_page.dart';
import 'package:brain_dev_firebase_login/views/information-screen/information_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteHelperAuth
{

  static getRouteLoginPage({String? redirect}) => RouteHelperBusinessAuth.getRouteLoginPage( redirect: redirect);
  static getRouteLoginPageWeb({String? redirect}) => RouteHelperBusinessAuth.getRouteLoginPageWeb(redirect: redirect);

  static getProfileScreen({ required String userId }) => RouteHelperBusinessAuth.getProfileScreen(userId: userId);
  static getInformationScreen({ required String page }) => RouteHelperBusinessAuth.getInformationScreen(page: page);

  static navLoginPageReplacement({String? redirect}) =>RouteHelperBusinessAuth.navLoginPageReplacement(redirect: redirect);

  //region [ NAVIGATOR PAGES ]
  static navToPage(String? redirect) {
    RouteHelperBusinessAuth.navToPage( redirect);
  }

  static navToReplacementPage(String redirect) {
    RouteHelperBusinessAuth.navToReplacementPage( redirect);
  }
  //endregion


  static navigateToInformationScreen(String title) {
    Navigator.push(
      Get.context!,
      MaterialPageRoute(
          builder: (context) => InformationScreen(information: title)),
    );
  }
  static navigateLoginPage({ String? redirect }) {
    Navigator.push(
      Get.context!,
      MaterialPageRoute(
          builder: (context) => LoginPage(redirect: redirect,)),
    );
  }
  static navigateLoginPageWeb({ String? redirect }) {
    Navigator.push(
      Get.context!,
      MaterialPageRoute(
          builder: (context) => LoginPage(redirect: redirect,)),
    );
  }

  static navProfileScreen({ required String userId }) => Navigator.pushNamed(Get.context!, getProfileScreen(userId: userId));

  static navLoginPage2({ String? redirect }) => Get.toNamed(getRouteLoginPage(redirect: redirect));
  static navLoginPage({ String? redirect }) => Navigator.pushNamed(Get.context!, getRouteLoginPage());
  static navLoginPageWeb({ String? redirect }) => Navigator.pushNamed(Get.context!, getRouteLoginPageWeb());
  static navLoginPageReplace() => Navigator.pushReplacementNamed(Get.context!, getRouteLoginPage());
  static navEditProfileScreen() => Navigator.pushNamed(Get.context!, RouteNameBusiness.editProfileScreen);
  static navInformationScreen({ required String page }) => Navigator.pushNamed(Get.context!, getInformationScreen(page: page));

}
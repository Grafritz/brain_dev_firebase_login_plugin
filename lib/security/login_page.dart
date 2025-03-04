import 'dart:async';

import 'package:brain_dev_business/controllers/business_controller.dart';
import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_business/models/users_model.dart';
import 'package:brain_dev_firebase_login/security/recovery_password_page.dart';
import 'package:brain_dev_firebase_login/security/register_page.dart';
import 'package:brain_dev_firebase_login/security/verify_email_page.dart';
import 'package:brain_dev_firebase_login/variables_firebase_login.dart';
import 'package:brain_dev_tools/I10n/localization_constants.dart';
import 'package:brain_dev_tools/config/app_config.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:brain_dev_tools/views/base/design_path/clip_path_design.dart';
import 'package:brain_dev_tools/tools/loading/wait_full_screen.dart';
import 'package:brain_dev_tools/tools/check_platform.dart';
import 'package:brain_dev_tools/tools/utils/color_resources.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import 'package:brain_dev_tools/tools/tools_log.dart';
import 'package:brain_dev_tools/tools/tools_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.redirect});
  final String? redirect;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //region [ attributs ]
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //final GoogleSignIn googleSignIn = GoogleSignIn(/*scopes: ['email']*/);
  User? currentUser;
  bool showProgressBar = false;
  bool isShowControls = false, showLoginWithEmailAnPassword = true;
  bool isEmailVerified = false;

  FirebaseAuthController firebaseAuthController = Get.find<FirebaseAuthController>();
  Timer? timer;
  ImageModel appImage = EnvironmentVariable.appImage;
  //endregion

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    //await firebaseAuth.currentUser?.reload();
    var firebaseAuth = FirebaseAuth.instance;
    currentUser = firebaseAuth.currentUser;
    isEmailVerified =
        currentUser == null ? false : currentUser!.emailVerified;
    if (!isEmailVerified) {
      //await sendVerificationEmail();
      //VerifyEmailPage();
    }
    try {} on Exception catch (ex, trace) {
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }

  Future checkVerificationEmail() async {
    var firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.currentUser!.reload();
    setState(() {
      isEmailVerified = firebaseAuth.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(builder: (userCtr) {
      return GetBuilder<FirebaseAuthController>(builder: (fUser) {
        currentUser = fUser.currentUser;
        return Scaffold(
          //backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Form(
                key: formKey,
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                        top: 10, left: 16.0, right: 16.0, bottom: 10.0),
                    //padding: const EdgeInsets.only(bottom: 120.0),
                    child: Stack(
                      children: <Widget>[
                        formLoginView(),
                        const ClipPathDesignRoundCornerTop(),
                        if( appImage.logoCircleLight.isNotEmpty )
                        Container(
                            margin: const EdgeInsets.only(top: 10.0),
                            alignment: Alignment.center,
                            height: 100,
                            child: Image.asset(
                              appImage.logoCircleLight,
                              fit: BoxFit.contain,
                            )),
                      ],
                    )),
              ),

              if (userCtr.showCircularProgress) const WaitFullScreen(),

              if (!fUser.isEmailVerified && fUser.currentUser != null)
                VerifyEmailPage(),
            ],
          ),
          bottomNavigationBar: senderGoogleAdsService.getWidgetBanner(),
        );
      });
    });
  }

  formLoginView() {
    if (kDebugMode) {
      emailController.text = 'duverseau.jeanfritz@gmail.com';
      passwordController.text = 'devesha';
    }
    return Container(
      margin: const EdgeInsets.only(top: 70),
      padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: ColorResources.setColorIsDark(colorIsNotDark: Colors.white)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30),
        child: GetBuilder<BusinessController>(builder: (userCtr) {
          UserModel? currentUser = userCtr.userConnected;
          return Column(
            children: <Widget>[
              if (currentUser.connecterYN)
                if (currentUser.photoPath != '')
                  Material(
                    elevation: 5.0,
                    shape: const CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 40.0,
                      backgroundImage: NetworkImage(
                        currentUser.photoPath,
                      ),
                    ),
                  ),

              const SizedBox(height: 10),
              if (showLoginWithEmailAnPassword)
                Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: tr('label_nom_utilisateur'),
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0)),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return '${tr('msg_required')}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      cursorColor: Theme.of(context).primaryColorDark,
                      decoration: InputDecoration(
                          hintText: tr('label_mot_de_passe'),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColorDark)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0)),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return '${tr('msg_required')}';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                        width: double.infinity,
                        child: MyElevatedButton(
                          style: elevatedButtonNormal(),
                          child: Text(tr('label_connexion').toUpperCase()),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await firebaseAuthController.signInWithEmailAndPassword(
                                      userName: emailController.text,
                                      password: passwordController.text, redirect: widget.redirect);
                            }
                          },
                        )),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const RecoveryPasswordPage()),
                        );
                      },
                      child: Text(
                        tr('msg_oublie_mot_de_passe'),
                        style: TextStyle(
                            color: ColorResources.setColorIsDark(
                                colorIsNotDark: Colors.red,
                                colorIsDark: Colors.white),
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterPage()),
                            )
                            .then((val) {});
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "${'msg_Dont_have_an_Account'.tr} ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.normal),
                          ),
                          Text('msg_create_an_account'.tr,
                              style: TextStyle(
                                  color: ColorResources.setColorIsDark(
                                      colorIsNotDark: Colors.red,
                                      colorIsDark: Colors.white),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline)),
                        ],
                      ),
                    ),
                  ],
                ),

              //if (isShowControls)
              if (CheckPlatform().isMobileOrWeb)
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Divider(
                      color: Colors.grey.shade600,
                    )),
                    const SizedBox(width: 10.0),
                    Text(
                      'msg_ou_connecter_avec'.tr,
                      style: ToolsWidget.smallText,
                    ),
                        const SizedBox(width: 10.0),
                        Expanded(
                            child: Divider(
                          color: Colors.grey.shade600,
                        )),
                      ],
                    ),
                  const SizedBox(
                    height: 5,
                  ),
                  //if (isShowControls)
                  if (CheckPlatform().isMobileOrWeb)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: SignInButton(
                          buttonType: ButtonType.google,
                          buttonSize: ButtonSize.medium,
                          width: double.infinity,
                          onPressed: () async {
                            await firebaseAuthController.signInWithGoogle(redirect: widget.redirect);
                          }),
                    ),
                    const SizedBox(height: 5),
                    if (!checkPlatform.isWeb && !checkPlatform.isAndroid)
                      SizedBox(
                        width: double.infinity,
                        child: SignInButton(
                            buttonType: ButtonType.apple,
                            buttonSize: ButtonSize.medium,
                            width: double.infinity,
                            onPressed: () async {
                              await firebaseAuthController.signInWithApple(redirect: widget.redirect);
                            }),
                      ),
                    if (kDebugMode)
                      SizedBox(
                      width: double.infinity,
                      child: SignInButton(
                          buttonType: ButtonType.facebook,
                          buttonSize: ButtonSize.medium,
                          width: double.infinity,
                          onPressed: () async {
                            await firebaseAuthController.signInWithFacebook(redirect: widget.redirect);
                          }),
                    ),

                  ],
                ),
              if (!showLoginWithEmailAnPassword)
                SizedBox(
                  width: double.infinity,
                  child: SignInButton(
                      buttonType: ButtonType.mail,
                      buttonSize: ButtonSize.medium,
                      width: double.infinity,
                      onPressed: () async {
                        setState(() {
                          showLoginWithEmailAnPassword =
                              !showLoginWithEmailAnPassword;
                        });
                      }),
                ),

              const SizedBox(
                height: 10,
              ),
              MyElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: elevatedButtonNormal(backgroundColor: Colors.blueGrey),
                child: Text(
                  "${tr('label_Annuler')}",
                ),
              ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              );
            }),
      ),
    );
  }

  showDialogProgress({bool show = true}) =>
      setState(() => showProgressBar = show);

}

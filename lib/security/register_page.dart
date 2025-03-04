import 'dart:async';

import 'package:brain_dev_business/controllers/business_controller.dart';
import 'package:brain_dev_firebase_login/config/routes/route_helper.dart';
import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_firebase_login/variables_firebase_login.dart';
import 'package:brain_dev_tools/I10n/localization_constants.dart';
import 'package:brain_dev_tools/config/app_config.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:brain_dev_tools/views/base/design_path/clip_path_design.dart';
import 'package:brain_dev_tools/tools/loading/wait_full_screen.dart';
import 'package:brain_dev_tools/tools/constant.dart';
import 'package:brain_dev_tools/tools/dialog_view.dart';
import 'package:brain_dev_tools/tools/tools_widget.dart';
import 'package:brain_dev_tools/tools/utils/color_resources.dart';
import 'package:brain_dev_tools/tools/validation/validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_button/sign_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.redirect});
  final String? redirect;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //region [ attributs ]
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool showProgressBar = false, _agree = false;
  bool isEmailVerified = false;

  Timer? timer2;
  User? currentUser;
  FirebaseAuthController firebaseAuthController = Get.find<FirebaseAuthController>();
  ImageModel appImage = EnvironmentVariable.appImage;
  //endregion

  @override
  void initState() {
    super.initState();

    initData();
  }

//int i=1;
  initData() async {
    //await firebaseAuth.currentUser?.reload();
    var firebaseAuth = FirebaseAuth.instance;
    currentUser = firebaseAuth.currentUser;
    isEmailVerified =
        currentUser == null ? false : currentUser!.emailVerified;
    if (!isEmailVerified) {
      //await sendVerificationEmail();
    }
  }

  Future checkVerificationEmail() async {
    var firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.currentUser!.reload();
    setState(() {
      currentUser = firebaseAuth.currentUser;
      isEmailVerified = firebaseAuth.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer2?.cancel();
  }

  @override
  void dispose() {
    timer2?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessController>(builder: (userCtr) {
      return Scaffold(
        //backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                    top: 0, left: 16.0, right: 16.0, bottom: 10.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 70),
                      padding: const EdgeInsets.only(
                          top: 40.0, left: 16.0, right: 16.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: ColorResources.setColorIsDark(
                              colorIsNotDark: Colors.white)),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10.0),
                            TextFormField(
                              controller: _fullNameController,
                              //keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: tr('label_Full_Name'),
                                  hintText: tr('label_Full_Name'),
                                  prefixIcon: Icon(
                                    Icons.contacts,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 13)),
                              // ignore: missing_return
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return '${tr('label_Full_Name')} ${tr('msg_required')}';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10.0),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: tr('label_email_account'),
                                  hintText: tr('label_email_account'),
                                  prefixIcon: Icon(
                                    Icons.account_circle,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 13)),
                              // ignore: missing_return
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '${tr('label_email_account')} ${tr('msg_required')}';
                                } else if (!isEmail(value)) {
                                  return '${tr('msg_ERROR_INVALID_EMAIL')}';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10.0),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              //keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: tr('label_mot_de_passe'),
                                  hintText: tr('label_mot_de_passe'),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 13)),
                              // ignore: missing_return
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '${tr('label_mot_de_passe')} ${tr('msg_required')}';
                                } else if (value.length < 6) {
                                  return '${tr('error_invalid_password_caractere')}';
                                } else if (value == _emailController.text) {
                                  return 'invalid password: most different with email'
                                      .tr;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10.0),

                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              //keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                  labelText: tr('label_confirm_mot_de_passe'),
                                  hintText: tr('label_confirm_mot_de_passe'),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColorDark)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 13)),
                              // ignore: missing_return
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '${tr('label_confirm_mot_de_passe')} ${tr('msg_required')}';
                                } else if (value != _passwordController.text) {
                                  return '${tr('label_confirm_mot_de_passe_check')}';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              tr('msg_agree_Terms_Conditions'),
                              style: ToolsWidget.smallText,
                            ),
                            buildCheckboxTile(),
                            const SizedBox(height: 10.0),
                            SizedBox(
                                width: double.infinity,
                                child: MyElevatedButton(
                                  style: elevatedButtonNormal(),
                                  child:
                                  Text(tr('label_Sign_Up').toUpperCase()),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      if (!_agree) {
                                        DialogView.showToast(
                                            'you_need_to_agree'.tr);
                                        return;
                                      }
                                      await firebaseAuthController
                                          .createWithEmailAndPassword(
                                          nomComplet: _fullNameController.text.trim(),
                                          userName:_emailController.text.trim(),
                                          password:_passwordController.text);
                                    }
                                  },
                                )),
                            const SizedBox(height: 10.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade600,
                                    )),
                                const SizedBox(width: 10.0),
                                Text(
                                  tr('msg_Already_have_account'),
                                  style: ToolsWidget.smallText,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                    child: Divider(
                                      color: Colors.grey.shade600,
                                    )),
                              ],
                            ),
                            //const SizedBox(height: 20.0),

                            SignInButton(
                                buttonType: ButtonType.mail,
                                buttonSize: ButtonSize.medium,
                                width: double.infinity,
                                onPressed: () async {
                                  RouteHelperAuth.navLoginPageReplacement();
                                }),
                            const SizedBox(height: 5),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              style: elevatedButtonNormal(
                                  backgroundColor: Colors.blueGrey),
                              child: Text("${tr('label_Annuler')}"),
                            ),
                            const SizedBox(height: 5.0),
                            linkTermsOfService(),
                            const SizedBox(height: 10.0),
                          ],
                        ),
                      ),
                    ),
                    const ClipPathDesignRoundCornerTop(),
                    if( appImage.logoCircleLight.isNotEmpty )
                    Container(
                        margin: const EdgeInsets.only(bottom: 70),
                        alignment: Alignment.center,
                        height: 90,
                        child: Image.asset(
                          appImage.logoCircleLight,
                          fit: BoxFit.contain,
                        )),
                  ],
                ),
              ),
            ),
            if (userCtr.showCircularProgress) const WaitFullScreen(),
          ],
        ),
        bottomNavigationBar: senderGoogleAdsService.getWidgetBanner(),
      );
    });
  }

  linkTermsOfService() {
    final t1 = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).primaryColor,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        InkWell(
          onTap: () =>
              RouteHelperAuth.navigateToInformationScreen(Constant.privacy_policy),
          child: Text('${'privacy_policy'.tr} ', style: t1),
        ),
        InkWell(
          onTap: () => RouteHelperAuth.navigateToInformationScreen(Constant.terms_and_conditions),
          child: Text('${'terms_and_conditions'.tr} ', style: t1),
        ),
      ],
    );
  }

  buildCheckboxTile() {
    return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: _agree,
        dense: true,
        //contentPadding: const EdgeInsets.all(3),
        checkColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        // checkColor: theme.isDarkTheme() ? Colors.white70 : Colors.black87,
        onChanged: (state) {
          setState(() {
            _agree = state!;
          });
        },
        title: RichText(
          text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.7),
              ),
              children: <TextSpan>[
                TextSpan(text: '${'i_agree_to_the'.tr} '),
                TextSpan(
                  text: 'terms_of_service'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                TextSpan(text: ' ${'and'.tr} '),
                TextSpan(
                  text: 'the_privacy_policy'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).primaryColor,
                  ),
                  //recognizer: TapGestureRecognizer()..onTap = () {
                  //navigateToInformationScreen('Terms & Conditions');
                  //}
                ),
              ]),
        )
        //Text('${'i_agree_to_the'.tr} ')
        /*
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.7),
            ),
            children: <TextSpan>[
              TextSpan(text: '${'i_agree_to_the'.tr} '),
              TextSpan(
                text: 'terms_of_service'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () =>
                      navigateToInformationScreen('Terms & Conditions'),
              ),
              TextSpan(text: ' ${'and'.tr} '),
              TextSpan(
                text: 'the_privacy_policy'.tr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).primaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap =() => navigateToInformationScreen('Privacy Policy'),
              ),
            ],
          ),
        )*/
        );
  }

  showDialogProgress({bool show = true}) =>
      setState(() => showProgressBar = show);
}

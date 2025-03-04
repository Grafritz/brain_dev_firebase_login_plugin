
import 'package:brain_dev_firebase_login/config/routes/route_helper.dart';
import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_firebase_login/variables_firebase_login.dart';
import 'package:brain_dev_tools/I10n/localization_constants.dart';
import 'package:brain_dev_tools/config/app_config.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:brain_dev_tools/views/base/design_path/clip_path_design.dart';
import 'package:brain_dev_tools/tools/loading/wait_full_screen.dart';
import 'package:brain_dev_tools/tools/tools_widget.dart';
import 'package:brain_dev_tools/tools/utils/color_resources.dart';
import 'package:brain_dev_tools/tools/validation/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_button/sign_button.dart';

class RecoveryPasswordPage extends StatefulWidget {
  const RecoveryPasswordPage({super.key, this.redirect});
  final String? redirect;

  @override
  State<RecoveryPasswordPage> createState() => _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends State<RecoveryPasswordPage> {
  //region [ attributs ]
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool showProgressBar = false;
  FirebaseAuthController firebaseAuthController = Get.find<FirebaseAuthController>();
  ImageModel appImage = EnvironmentVariable.appImage;
  //endregion

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          //Twid().bgImageSplashScreenLight(),
          Form(
            key: _formKey,
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                  top: 70, left: 16.0, right: 16.0, bottom: 10.0),
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
                          Text(tr('label_title_reset_password').toUpperCase()),
                          const SizedBox(height: 15.0),
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
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.email_outlined),
                                style: elevatedButtonNormal(),
                                label: Text(
                                    tr('label_reset_password').toUpperCase()),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    await firebaseAuthController
                                        .sendPasswordResetEmail( userName: _emailController.text.trim());
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

                          const SizedBox(
                            height: 5,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            style: elevatedButtonNormal(
                                backgroundColor: Colors.blueGrey),
                            child: Text("${tr('label_Annuler')}"),
                          ),
                          const SizedBox(height: 20.0),
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
          if (showProgressBar) const WaitFullScreen(),
        ],
      ),
      bottomNavigationBar: senderGoogleAdsService.getWidgetBanner(),
    );
  }

  showDialogProgress({bool show = true}) =>
      setState(() => showProgressBar = show);

}

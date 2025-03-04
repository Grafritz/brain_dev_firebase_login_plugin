
import 'package:brain_dev_firebase_login/variables_firebase_login.dart';
import 'package:brain_dev_tools/controllers/application_controller.dart';
import 'package:brain_dev_tools/controllers/theme_controller.dart';
import 'package:brain_dev_tools/models/settings_model.dart';
import 'package:brain_dev_tools/tools/constant.dart';
import 'package:brain_dev_tools/tools/my_launcher.dart';
import 'package:brain_dev_tools/tools/tools_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
//import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatefulWidget {
  final String? information;

  const InformationScreen({super.key, this.information});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  String? _information;
  late ApplicationController applicationController = Get.find<ApplicationController>();

  @override
  void initState() {
    super.initState();
    initStateData();
  }

  initStateData() async {
    try {
      await applicationController.fetchSettings();
      if (widget.information == Constant.privacy_policy) {
        _information = applicationController.settings.privacyPolicy;
      } else if (widget.information == Constant.terms_and_conditions) {
        _information = applicationController.settings.termsAndConditions;
      } else {
        _information = applicationController.settings.privacyPolicy;
      }
      applicationController.showCircularProgressIndicator(show: false);
    } catch (ex, trace) {
      logError(ex, trace: trace, position: 'initStateData');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: body(),
      bottomNavigationBar: senderGoogleAdsService.getWidgetBanner(),
    );
  }

  appBar() {
    return AppBar(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        widget.information != null
            ? widget.information!.tr
            : Constant.privacy_policy,
        style: const TextStyle(color: Colors.black, fontFamily: 'Brandon'),
      ),
    );
  }

  body() {
    return GetBuilder<ThemeController>(builder: (themeCtr) {
        return GetBuilder<ApplicationController>(builder: (app) {
          SettingsModel settings = SettingsModel(id: '');
          settings = app.settings;
          if (widget.information == Constant.privacy_policy) {
            _information = settings.privacyPolicy;
          } else if (widget.information == Constant.terms_and_conditions) {
            _information = settings.termsAndConditions;
          } else {
            _information = settings.privacyPolicy;
          }
          return SingleChildScrollView(
              child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
            child: _information != null
                ? HtmlWidget('$_information',
              onTapUrl: (url) {
                MyLauncher.launchInWebViewOrVC(url);
                return true;
              },
              textStyle: TextStyle(
                  letterSpacing: themeCtr.letterSpacing,
                  fontSize: themeCtr.fontSize,
                  wordSpacing: themeCtr.wordSpacing),
            )
                // Html(
                //     data: _information,
                //     shrinkWrap: true,
                //     onLinkTap: (url, attributes, element) async {
                //       Uri uri = Uri.parse(url!);
                //       if (await canLaunchUrl(uri)) {
                //         await launchUrl(uri);
                //       } else {
                //         throw 'Could not launch $url';
                //       }
                //     },
                //     style: {
                //       "body": Style(
                //         textAlign: TextAlign.justify,
                //         fontSize: FontSize.medium,
                //         fontWeight: FontWeight.normal,
                //       ),
                //     },
                //     /*onImageTap: (url, context, attributes, element) async {
                //       Uri uri = Uri.parse(url!);
                //       if (await canLaunchUrl(uri)) {
                //         await launchUrl(uri);
                //       } else {
                //         throw 'Could not launch $url';
                //       }
                //     },*/
                //   )
                : const SizedBox(
                    height: 450,
                    child: Center(
                      child: Text(
                        'No Privacy Policy Available',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          ));
        });
      }
    );
  }
}

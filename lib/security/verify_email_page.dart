import 'dart:async';

import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_tools/controllers/application_controller.dart';
import 'package:brain_dev_tools/I10n/localization_constants.dart';
import 'package:brain_dev_tools/tools/loading/wait_full_screen.dart';
import 'package:brain_dev_tools/tools/dialog_view.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:brain_dev_tools/tools/tools_log.dart';
import 'package:brain_dev_tools/tools/tools_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, this.assetsLogoPath, this.widgetBannerBottomNavigation});
  final String? assetsLogoPath;
  final Widget? widgetBannerBottomNavigation;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  //region [ attributs ]
  bool showProgressBar = false;
  bool isEmailVerified = false;
  User? currentUser;
  Timer? _timer;
  int _count = 1;
  final int _countLimit = 116;

  //late FirebaseAuthBloc firebaseAuthBloc = BlocProvider.of<FirebaseAuthBloc>(context);
  FirebaseAuthController firebaseAuthController = Get.find<FirebaseAuthController>();
  ApplicationController applicationController = Get.find<ApplicationController>();

  //endregion

  @override
  void initState() {
    super.initState();

    initData();
  }

  initData() async {
    firebaseAuthController.checkVerificationEmailAction();
    setTimer();
  }

  setTimer() async {
    _timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => checkVerificationEmail());
  }

  Future checkVerificationEmail() async {
    applicationController.counter = _count;
    applicationController.duration = Duration(seconds: _countLimit - _count);
    //logCat('count: $_count || countLimit-_count: ${(_countLimit - _count)}');
    if (_countLimit == _count) {
      _timer?.cancel();
      _count = 0;
      applicationController.counter = _count;
      applicationController.duration = Duration(seconds: _countLimit - _count);
      //logCat('count: $_count || countLimit: ${(_countLimit - _count)}');
      await firebaseAuthController.checkVerificationEmailAction();
    }
    _count++;
  }


  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApplicationController>(builder: (applicationCtr) {
      return GetBuilder<FirebaseAuthController>(builder: (firebaseAuthCtr) {
        currentUser = firebaseAuthCtr.currentUser;
        return Stack(
          children: [
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black87,
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'msg_reset_password'.trParams(
                          {'yourEmail': currentUser?.email ?? ''}),
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (applicationCtr.counter > 0)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.lock_reset),
                        style: elevatedButtonNormal(backgroundColor: Colors.teal),
                        label: Text('label_check_verification_email'.trParams({
                          'counter': ToolsWidget() .formatTime(duration: applicationCtr.duration)
                        })),
                        onPressed: () async {
                          await firebaseAuthController
                              .checkVerificationEmailAction();
                        },
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (currentUser?.displayName != null)
                      Text(
                        currentUser?.displayName ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    Text(
                      currentUser?.email ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.email_outlined),
                          style: elevatedButtonNormal(),
                          label: Text(tr('label_resend_verification_email')
                              .toUpperCase()),
                          onPressed: () async {
                            await sendVerificationEmail();
                          },
                        )),
                    const SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        const Expanded(
                            child: Divider(
                          color: Colors.white,
                        )),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(tr('msg_if_is_not_you'),
                            style:
                                const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 10.0),
                        const Expanded(
                            child: Divider(
                          color: Colors.white,
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          style: elevatedButtonNormal(backgroundColor: Colors.indigo),
                          label: Text(tr('label_Modifier_email').toUpperCase()),
                          onPressed: () async {
                            await deleteEmailAndSignOut();
                          },
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          style: elevatedButtonNormal(backgroundColor: Colors.blueGrey),
                          label: Text(tr('label_connect_with_another_Account')
                              .toUpperCase()),
                          onPressed: () async {
                            await signOutAndGotoLogin();
                          },
                        )),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("${tr('label_Annuler')}",
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              decoration: TextDecoration.underline)),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
            if (showProgressBar) const WaitFullScreen(),
          ],
        );
      });
    });
  }

  showDialogProgress({bool show = true}) =>
      setState(() => showProgressBar = show);

  Future<void> sendVerificationEmail() async {
    try {
      showDialogProgress();
      var firebaseAuth = FirebaseAuth.instance;
      final user = firebaseAuth.currentUser!;
      await user.sendEmailVerification();
      showDialogProgress(show: false);
      setTimer();
      DialogView.showAlertDialog(
          eors: 'S',
          msg: 'msg_reset_password'.trParams({'yourEmail': user.email!}));
      applicationController.counter = 1;
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on Exception catch (ex, trace) {
      showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }

  Future<void> deleteEmailAndSignOut() async {
    try {
      showDialogProgress();
      var firebaseAuth = FirebaseAuth.instance;
      final user = firebaseAuth.currentUser!;
      await user.delete();
      await firebaseAuth.signOut();
      showDialogProgress(show: false);

      Navigator.of(Get.context!).pop(true);
      //DialogView.showAlertDialog(context: context, eors: 'S', msg: msg_reset_password(user.email!) );
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on Exception catch (ex, trace) {
      showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }

  Future<void> signOutAndGotoLogin() async {
    try {
      var firebaseAuth = FirebaseAuth.instance;
      await firebaseAuth.signOut();
      Navigator.of(Get.context!).pop(true);
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on Exception catch (ex, trace) {
      showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }
}

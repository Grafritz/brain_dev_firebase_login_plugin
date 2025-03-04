import 'dart:io';

import 'package:brain_dev_business/config/routes/route_helper_business_auth.dart';
import 'package:brain_dev_business/controllers/business_controller.dart';
import 'package:brain_dev_business/repository/user_repository.dart';
import 'package:brain_dev_business/models/users_model.dart';
import 'package:brain_dev_business/services/sender_firebase_message_service.dart';
import 'package:brain_dev_firebase_login/security/delete_profil_dialog.dart';
import 'package:brain_dev_tools/I10n/localization_constants.dart';
import 'package:brain_dev_tools/models/message_model.dart';
import 'package:brain_dev_tools/tools/check_platform.dart';
import 'package:brain_dev_tools/tools/constant.dart';
import 'package:brain_dev_tools/tools/dialog_view.dart';
import 'package:brain_dev_tools/tools/tools_log.dart';
import 'package:brain_dev_tools/tools/utils/utils.dart';
import 'package:brain_dev_tools/tools/exception/text_empty_exception.dart';
import 'package:brain_dev_tools/tools/validation/type_safe_conversion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseAuthController extends GetxController implements GetxService {
  //region [ ATTRIBUTE ]
  final SharedPreferences sharedPreferences;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  bool get isEmailVerified => firebaseAuth.currentUser?.emailVerified ?? false;
  BusinessController businessController = Get.find<BusinessController>();
  //endregion

  //region [ ATTRIBUTE ]
  User? _user;
  User? get currentUserFireBase => _user;
  bool _isEmailVerified = false;

  bool get isEmailVerifiedSink => _isEmailVerified;

  //endregion
  UserRepository userRepository;
  final SenderFirebaseMessageService senderFirebaseMessageService;

  FirebaseAuthController({
      required this.senderFirebaseMessageService,
      required this.userRepository,
      required this.sharedPreferences})
  {
    _isEmailVerified = false;
    initFirebaseAuth();
  }

  initFirebaseAuth() {
    if (checkPlatform.isMobileOrWeb) {
      firebaseAuth.authStateChanges().listen((User? value) {
        //logCat('IN FirebaseAuthBloc :: .authStateChanges()');
        _user = value;
        _isEmailVerified = value == null ? false : value.emailVerified;
        update();
      });
      firebaseAuth.userChanges().listen((User? value) {
        //logCat('IN FirebaseAuthBloc :: .userChanges()');
        _user = value;
        _isEmailVerified = value == null ? false : value.emailVerified;
        update();
      });
    }
  }

  bool _showProgressBar = false;

  bool get showProgressBar => _showProgressBar;

  showDialogProgress({bool show = true}) {
    _showProgressBar = show;
    update();
  }


//region [ Verification ]
  Future checkVerificationEmailAction() async {
    showDialogProgress();
    var firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.currentUser!.reload();
    _user = firebaseAuth.currentUser;
    _isEmailVerified = firebaseAuth.currentUser!.emailVerified;
    update();
    showDialogProgress(show: false);
    if (_isEmailVerified) {
      //RouteHelper.navToReplacementPage(RouteName.pageLoginPage);
    } else {
      DialogView.showToast('msg_reset_password'.trParams({'yourEmail': currentUser?.email ?? ''}));
    }
  }

  //endregion
//region [ Login Firebase ]
  Future signInWithEmailAndPassword(
      {required String userName,
      required String password,
      String? redirect}) async
  {
    try {
      businessController.showCircularProgressIndicator(show: true);
      var dataUser = await firebaseAuth.signInWithEmailAndPassword(
          email: userName, password: password);
      UserModel user = UserModel();
      user = await userRepository.getUserUI(currentUser: dataUser.user);
      user.userName = userName;
      user.motDePasse = password;
      user.userCreated = 'email';
      await loginRegisterProvider(user: user, redirect: redirect);
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      businessController.showCircularProgressIndicator(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      businessController.showCircularProgressIndicator(show: false);
      DialogView.showAlertDialog(msg: getErrorMessage(ex));
    } on Exception catch (ex, trace) {
      businessController.showCircularProgressIndicator(show: false);
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }

  Future sendPasswordResetEmail({required String userName}) async
  {
    try {
      businessController.showDialogProgress(show: true);
      await firebaseAuth.sendPasswordResetEmail(email: userName);
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(
          eors: 'S',
          msg: 'msg_reset_password'.trParams({'yourEmail': userName}));
      DialogView.showToast( 'msg_reset_password'.trParams({'yourEmail': userName}),eors: 'S',);

      //Navigator.of(Get.context!).pop(true);
      RouteHelperBusinessAuth.navLoginPageReplacement();
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on Exception catch (ex, trace) {
      businessController.showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = currentUser!;
      await user.sendEmailVerification();
      DialogView.showAlertDialog(
          eors: 'S',
          msg: 'msg_reset_password'.trParams({'yourEmail': user.email!}));
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on Exception catch (ex, trace) {
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
    businessController.showDialogProgress(show: false);
  }

//endregion

//region [ signIn With Google ]
  Future<void> signInWithGoogle({String? redirect}) async {
    try {
      businessController.showDialogProgress(show: true);
      var firebaseAuth = FirebaseAuth.instance;
      UserCredential userCredential;
      if (CheckPlatform().isWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleSignInAccount =
            await GoogleSignIn().signIn();
        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
            await googleSignInAccount?.authentication;
        // Create a new credential
        final OAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        // Once signed in, get the credential
        userCredential =
            await firebaseAuth.signInWithCredential(googleAuthCredential);
      }
      UserModel user = UserModel();
      //currentUser = userCredential.user;
      user = await userRepository.getUserUI(currentUser: userCredential.user);
      user.userName =
          TypeSafeConversion.nullSafeString(userCredential.user?.email);
      user.motDePasse = user.userName;
      user.userCreated = 'google';
      //currentUserSink.add(userCredential.user);
      //isEmailVerified = userCredential.user!.emailVerified);
      await loginRegisterProvider(redirect: redirect, user: user);
    } on PlatformException catch (ex, trace) {
      logCat('code:${ex.code} | message:${ex.message}');
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: getErrorMessage(ex));
      logError(ex, trace: trace, position: 'signInWithGoogle');
      signOut();
      update();
    } on Exception catch (ex, trace) {
      DialogView.showAlertDialog(msg: 'msg_TraitementImpossible'.tr);
      businessController.showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithGoogle');
      signOut();
    } catch (ex, trace) {
      logError(ex, trace: trace, position: 'signInWithGoogle');
      signOut();
    }
    businessController.showDialogProgress(show: false);
  }

  void signOut() async {
    try {
      //await googleSignIn.signOut();
      businessController.signOut();
      //await FirebaseAuth.instance.signOut();
      //await GoogleSignIn().signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn();
      //final fbAccessToken = await FacebookAuth.instance.accessToken;
      //final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      if (await googleSignIn.isSignedIn()) {
        await firebaseAuth.signOut().then((_) {
          googleSignIn.signOut();
        });
      }
      //RouteHelper.navLoginPage();
      // else if (fbAccessToken != null) {
      //   await firebaseAuth.signOut().then((_) async {
      //     await FacebookAuth.instance.logOut();
      //   });
      // }
      businessController.signOut();
      //applicationBloc?.selectPage(0);
      /*UserModel usersModel = UserModel(id: 0, connecterYN: false);
      if( defaultTargetPlatform == TargetPlatform.windows ){
        globalSessionPref.setUsers(usersModel);
        userBloc.userConnectedSink.add(usersModel);
        Tools.logCat('signOut OK');
      }
      if( kIsWeb || CheckPlatform().isMobile ) {
        await _auth.signOut().then((value) async {
          //_userConnected.connecterYN = false;
          await _googleSignIn.signOut();
          //_userConnected = UsersModel();
          globalSessionPref.setUsers(usersModel);
          userBloc.userConnectedSink.add(usersModel);
          Tools.logCat('signOut OK');
          //Navigator.of(context).pop(true);
        });
      }*/
    } catch (ex, trace) {
      logError(ex, trace: trace, position: 'signInWithGoogle');
    }
  }

//endregion

//region [ signIn With Apple ]
  Future<void> signInWithApple({String? redirect}) async {
    try {
      businessController.showDialogProgress(show: true);
      var firebaseAuth = FirebaseAuth.instance;
      //final result = await TheAppleSignIn.performRequests([AppleIdRequest(requestedScopes: scopes)]);
      UserCredential userCredential;
      // Trigger the authentication flow
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: 'your_client_id',
        //   redirectUri: Uri.parse('your_redirect_uri'),
        // ),
      );

      // Create a new credential
      final OAuthCredential appleAuthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Once signed in, get the credential
      userCredential = await firebaseAuth.signInWithCredential(appleAuthCredential);

      UserModel user = UserModel();
      user = await userRepository.getUserUI(currentUser: userCredential.user);
      user.userName = TypeSafeConversion.nullSafeString(userCredential.user?.email);
      user.motDePasse = '.';
      user.userCreated = 'apple';

      await loginRegisterProvider(redirect: redirect, user: user);
    } on PlatformException catch (ex, trace) {
      logCat('code:${ex.code} | message:${ex.message}');
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: getErrorMessage(ex));
      logError(ex, trace: trace, position: 'signInWithApple');
      signOut();
      update();
    } on Exception catch (ex, trace) {
      DialogView.showAlertDialog(msg: 'msg_TraitementImpossible'.tr);
      businessController.showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithApple');
      signOut();
    } catch (ex, trace) {
      logError(ex, trace: trace, position: 'signInWithApple');
      signOut();
    }
    businessController.showDialogProgress(show: false);
  }

//endregion

//region [ signIn With Facebook ]
  Future<void> signInWithFacebook({String? redirect}) async {
    try {
      // userController.showDialogProgress(show: true);
      // var firebaseAuth = FirebaseAuth.instance;
      // UserCredential userCredential;
      // // Trigger the authentication flow
      // final LoginResult loginResult = await FacebookAuth.instance.login(
      //     // loginTracking: LoginTracking.limited,
      //     // nonce: Generator().generateNonce(),
      //     );
      // switch (loginResult.status) {
      //   case LoginStatus.success:
      //   //await _getUserProfile(loginResult.accessToken!);
      //   case LoginStatus.cancelled:
      //   case _:
      //     logCat(
      //         'status.name:${loginResult.status.name} | message:${loginResult.message}');
      // }
      // //if (loginResult.status == LoginStatus.success) {
      // if (CheckPlatform().isWeb) {
      //   FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      //   facebookProvider.addScope('email');
      //   facebookProvider.setCustomParameters({
      //     'display': 'popup',
      //   });
      //   userCredential =
      //       await FirebaseAuth.instance.signInWithPopup(facebookProvider);
      // } else {
      //   // TODO: A verifier [accessToken] https://github.com/darwin-morocho/flutter-facebook-auth/blob/master/facebook_auth/example/lib/login_page.dart
      //   // Create a credential from the access token
      //   final OAuthCredential oAuthCredential =
      //       FacebookAuthProvider.credential(loginResult.accessToken!.token);
      //   //final OAuthCredential oAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      //   // Once signed in, get the credential
      //   userCredential =
      //       await firebaseAuth.signInWithCredential(oAuthCredential);
      //   //userCredential = await firebaseAuth.signInWithCustomToken(loginResult.accessToken!.tokenString);
      // }
      //
      // UserModel user = UserModel();
      // //currentUser = userCredential.user;
      // user = await userRepository.getUserUI(currentUser: userCredential.user);
      // user.userName =
      //     TypeSafeConversion.nullSafeString(userCredential.user?.email);
      // user.motDePasse = user.userName;
      // user.userCreated = 'facebook';
      // //firebaseAuthBloc.currentUserSink.add(userCredential.user);
      // //firebaseAuthBloc.isEmailVerifiedSink.add(userCredential.user!.emailVerified);
      // await loginRegisterProvider(user: user, redirect: redirect);
      // userController.showDialogProgress(show: false);
      // update();
      // //RouteHelper.navToPage(redirect);
    } on PlatformException catch (ex, trace) {
      logCat('code:${ex.code} | message:${ex.message}');
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: getErrorMessage(ex));
      logError(ex, trace: trace, position: 'signInWithFacebook');
      signOut();
    } on Exception catch (ex, trace) {
      DialogView.showAlertDialog(msg: 'msg_TraitementImpossible'.tr);
      businessController.showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithFacebook');
      signOut();
    } catch (ex, trace) {
      businessController.showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithGoogle');
      signOut();
    }
  }
//endregion

//region [ createWithEmailAndPassword ]

  Future<void> createWithEmailAndPassword(
      {required String nomComplet,
      required String userName,
      required String password}) async {
    try {
      businessController.showDialogProgress(show: true);
      var firebaseAuth = FirebaseAuth.instance;
      var dataUser = await firebaseAuth.createUserWithEmailAndPassword(
          email: userName, password: password);
      UserModel user = UserModel();
      user = await userRepository.getUserUI(currentUser: dataUser.user);
      user.nomComplet = nomComplet;
      user.userName = userName;
      user.motDePasse = password;
      await sendVerificationEmail();
      businessController.showDialogProgress(show: false);
      //openPage();
      //RouteHelper.navToReplacementPage(RouteName.pageLoginPage);
      Navigator.pop(Get.context!);
    } on FirebaseAuthException catch (ex, trace) {
      logCat(ex.code);
      logCat(ex.message!);
      logError(ex, trace: trace, position: 'FirebaseAuthException');
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on PlatformException catch (ex, trace) {
      logError(ex, trace: trace, position: 'PlatformException');
      logCat(ex.code);
      logCat(ex.message!);
      businessController.showDialogProgress(show: false);
      DialogView.showAlertDialog(eors: 'E', msg: ex.message!);
    } on Exception catch (ex, trace) {
      businessController.showDialogProgress(show: false);
      logError(ex, trace: trace, position: 'signInWithEmailAndPassword');
    }
  }

//endregion

  //region [ Auth From Server ]
  Future<void> loginRegisterProvider({required UserModel user, String? redirect}) async {
    try {
      businessController.showDialogProgress(show: true);
      var userObj = await userRepository.loginRegisterProvider(user: user);
      businessController.showDialogProgress(show: false);
      if (userObj == null) {
        DialogView.showAlertDialog(msg: 'msg_TraitementImpossible'.tr);
        update();
        return;
      }
      businessController.setUserConnected(user: userObj);
      businessController.getUserConnected();
      await senderFirebaseMessageService.getDeviceToken();
      await Get.find<SenderFirebaseMessageService>().getDeviceToken();
      String msgWelCome = '${'msg_Welcome_again'.tr} ${userObj.nomComplet}';
      DialogView.showToast(msgWelCome);
      //getActionsAfter(users: usersModel);
      businessController.showDialogProgress(show: false);
      //Navigator.of(context).pop(true);
      update();
      String rn0 = TypeSafeConversion.nullSafeString(redirect);
      if( rn0==Constant.closeAfter) {
        Navigator.of(Get.context!).pop(true);
        businessController.showDialogProgress(show: false);
        return;
      }
      //Navigator.pushReplacementNamed(context, rn);
      //RouteHelperAuth.navToReplacementPage(rn0);
      Navigator.of(Get.context!).pop(true);
    } on SocketException catch (ex, trace) {
      setConnectivity();
      logError(ex, trace: trace, position: 'SocketException::loginOnServer');
    } on TextEmptyException catch (ex, trace) {
      DialogView.showAlertDialog(msg: 'msg_username_incorrect'.tr);
      logError(ex, trace: trace, position: 'login');
    } on Exception catch (ex, trace) {
      DialogView.showAlertDialog(msg: 'msg_TraitementImpossible'.tr);
      logError(ex,
          trace: trace, position: 'Utilities.Exception::loginOnServer');
    } catch (ex, trace) {
      DialogView.showAlertDialog(msg: 'msg_TraitementImpossible'.tr);
      logError(ex, trace: trace, position: 'catch::loginOnServer');
    }
    businessController.showDialogProgress(show: false);
  }

  String getErrorMessage(PlatformException e) {
    switch (e.code) {
      case 'ERROR_INVALID_EMAIL': // -  If the [email] address is malformed.
        return 'msg_ERROR_INVALID_EMAIL'.tr;
      case 'ERROR_WRONG_PASSWORD': // -  If the [password] is wrong.
        return 'msg_ERROR_WRONG_PASSWORD'.tr;
      case 'ERROR_USER_NOT_FOUND': // -  If there is no user corresponding to the given [email] address, or if the user has been deleted.
        return 'msg_ERROR_USER_NOT_FOUND'.tr;
      case 'ERROR_USER_DISABLED': // -  If the user has been disabled (for example, in the Firebase console)
        return 'msg_ERROR_USER_DISABLED'.tr;
      case 'ERROR_TOO_MANY_REQUESTS': // -  If there was too many attempts to sign in as this user.
        return 'msg_ERROR_TOO_MANY_REQUESTS'.tr;
      case 'ERROR_OPERATION_NOT_ALLOWED': // -  Indicates that Email & Password accounts are not enabled.
        return 'msg_ERROR_OPERATION_NOT_ALLOWED'.tr;
      case 'ERROR_WEAK_PASSWORD': // - If the password is not strong enough.
        return 'msg_ERROR_WEAK_PASSWORD'.tr;
      case 'ERROR_EMAIL_ALREADY_IN_USE': // - If the email is already in use by a different account.
        return 'msg_ERROR_EMAIL_ALREADY_IN_USE'.tr;
      // Google Sign
      case 'failed_to_recover_auth': // - Error code indicating there was a failed attempt to recover user authentication.
        return 'msg_failed_to_recover_auth'.tr;
      case 'user_recoverable_auth': // - Error indicating that authentication can be recovered with user action
        return 'msg_user_recoverable_auth'.tr;
      case 'sign_in_required': // - Error code indicating there is no signed in user and interactive sign in
        return 'msg_sign_in_required'.tr;
      case 'sign_in_canceled': // - Error code indicating that interactive sign in process was canceled by the user
        return 'msg_sign_in_canceled'.tr;
      case 'network_error': // - Error code indicating network error. Retrying should resolve the problem.
        return 'msg_network_error'.tr;
      case 'sign_in_failed': // - Error code indicating that attempt to sign in failed.
        return 'msg_sign_in_failed'.tr;

      case 'ERROR_INVALID_CREDENTIAL': // - The [email] address is malformed
        return 'msg_ERROR_INVALID_CREDENTIAL'.tr;
      case 'ERROR_NOT_ALLOWED': // - That email and email sign-in link accounts are not enabled. Enable them in the Auth section of the Firebase console
        return 'msg_ERROR_NOT_ALLOWED'.tr;
      case 'ERROR_DISABLED': // - The user's account is disabled
        return 'msg_ERROR_DISABLED'.tr;
      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL': // - There already exists an account with the email address asserted by Google
        return 'msg_ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL'.tr;
      case 'ERROR_INVALID_ACTION_CODE': // - The action code in the link is malformed, expired, or has already been used.
        return 'msg_ERROR_INVALID_ACTION_CODE'.tr;
      case 'ERROR_INVALID_CUSTOM_TOKEN': // - The custom token format is incorrect.
        return 'msg_ERROR_INVALID_CUSTOM_TOKEN'.tr;
      case 'ERROR_CUSTOM_TOKEN_MISMATCH': // - Invalid configuration.
        return 'msg_ERROR_CUSTOM_TOKEN_MISMATCH'.tr;
      case 'EXPIRED_ACTION_CODE': // - The password reset code has expired.
        return 'msg_EXPIRED_ACTION_CODE'.tr;
      case 'INVALID_ACTION_CODE': // - The password reset code is invalid. This can happen if the code is malformed or has already been used.
        return 'msg_INVALID_ACTION_CODE'.tr;
      case 'USER_DISABLED': // - The user corresponding to the given password reset code has been disabled.
        return 'msg_USER_DISABLED'.tr;
      case 'USER_NOT_FOUND': // - There is no user corresponding to the password reset code. This may have happened if the user was deleted between when the code was issued and when this method was called.
        return 'msg_USER_NOT_FOUND'.tr;
      case 'WEAK_PASSWORD': // - The new password is not strong enough.
        return 'msg_WEAK_PASSWORD'.tr;
      default:
        return '${('msg_TraitementImpossible'.tr)}\nCase ${e.message}';
    }
  }
  String getErrorMessageAPI({required int code, required String msg}) {
    switch ('$code') {
      case '${HttpStatus.badRequest}':// -S400_BAD_REQUEST
        return '${tr('ERROR_API_S400_BAD_REQUEST')}';

      case '${HttpStatus.unauthorized}':// -S401_UNAUTHORIZED
        return '${tr('ERROR_API_S401_UNAUTHORIZED')}';

      case '${HttpStatus.notFound}':// -S404_NOT_FOUND
        return '${tr('ERROR_API_S404_NOT_FOUND')}';

      case '${HttpStatus.serviceUnavailable}':// -S503_SERVICE_UNAVAILABLE
        return '${tr('ERROR_API_S503_SERVICE_UNAVAILABLE')}';

      case '${HttpStatus.ok}':// -S200_OK // msg_operation_success
        return '${tr('ERROR_API_S200_OK')}';
      default:
        return '${tr('msg_TraitementImpossible')}\nmsg $msg';
    }
  }

/*Future<void> loginOnServer({required String userName, required String password}) async {
    try {
      userController.showDialogProgress(show: true);
      await userRepository
          .authenticate(userName: userName, password: password)
          .then((userObj) {
        userController.showDialogProgress(show: false);
        userObj.connecterYN = true;
        userController.setUserConnected(user: userObj);

        String msgWelCome = '${'msg_Welcome_again'.tr} ${userObj.nomComplet}';
        DialogView.showToast(msgWelCome);
        //getActionsAfter(users: usersModel);
        userController.showDialogProgress(show: false);
        update();
        Get.back();
        //Navigator.of(context).pop(true);
      });
    } on SocketException catch (ex, trace) {
      setConnectivity();
      logError(ex, trace: trace, position: 'SocketException::loginOnServer');
    } on TextEmptyException catch (ex, trace) {
      DialogView.showAlertDialog(
          context: Get.context!, msg: 'msg_username_incorrect'.tr);
      logError(ex, trace: trace, position: 'login');
    } on Exception catch (ex, trace) {
      DialogView.showAlertDialog(
          context: Get.context!, msg: 'msg_TraitementImpossible'.tr);
      logError(ex,
          trace: trace, position: 'Utilities.Exception::loginOnServer');
    } catch (ex, trace) {
      DialogView.showAlertDialog(
          context: Get.context!, msg: 'msg_TraitementImpossible'.tr);
      logError(ex, trace: trace, position: 'catch::loginOnServer');
    }
    userController.showDialogProgress(show: false);
  }*/

//endregion

  //region [ Delete Account ]
  confirmationDeleteAccount() {
    return showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const DeleteProfilDialog();
        }).then((value) {
      if (value != null) {
        if (value.toString().isNotEmpty) {
          deleteAccount(raison: value.toString());
        }
      }
    });
  }

  confirmationDeleteAllDataAccount() {
    return showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const DeleteProfilDialog();
        }).then((value) {
      if (value != null) {
        if (value.toString().isNotEmpty) {
          deleteAllDataUser(raison: value.toString());
        }
      }
    });
  }

  deleteAccount({required String raison}) async {
    try {
      showDialogProgress(show: true);
      MessageModel message =
      await userRepository.deleteAccountOnTheCloud(raison: raison);
      if (message.isSuccess) {
        await deleteEmailOnFirebaseAndSignOut();
        DialogView.showToast(message.message);
        //userBloc.userConnectedSink.add(UserModel(id: 0, connecterYN: false));
        //UserRepository().setUserConnected(user: new UserModel(id: 0, connecterYN: false));
        showDialogProgress(show: false);
        Navigator.of(Get.context!).pop(true);
      } else {
        if (message.isRequiredToReLogin) {
          DialogView.showToast(message.message,
              eors: 'E', alignment: Alignment.bottomCenter);
          // Navigator.pushReplacementNamed(Get.context!, RouteName.pageLoginPage,
          //     arguments: Params(routeName: RouteName.pageProfilPage));
        }
        Navigator.of(Get.context!).pop(true);
        DialogView.showToast(message.message,
            eors: 'E', alignment: Alignment.center);
      }
    } on TextEmptyException catch (ex, trace) {
      showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: ex.message);
      logError(ex, trace: trace, position: 'getRefreshMiseAJourChant');
      //Navigator.of(context).pop(true);
    } on Exception catch (ex, trace) {
      showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: gtr('msg_TraitementImpossible'));
      logError(ex, trace: trace, position: 'getRefreshMiseAJourChant');
    }
  }

  deleteAllDataUser({required String raison}) async {
    try {
      showDialogProgress(show: true);
      MessageModel message = await userRepository.deleteAllDataOnTheCloud(raison: raison);
      if (message.isSuccess) {
        await deleteEmailOnFirebaseAndSignOut();
        DialogView.showToast(message.message);
        showDialogProgress(show: false);
        Navigator.of(Get.context!).pop(true);
      } else {
        if (message.isRequiredToReLogin) {
          DialogView.showToast(message.message, eors: 'E', alignment: Alignment.bottomCenter);
          // Navigator.pushReplacementNamed(
          //     Get.context!,
          //     RouteName.pageLoginPage,
          //     arguments: Params(routeName: RouteName.pageProfilPage));
        }
        Navigator.of(Get.context!).pop(true);
        DialogView.showToast(message.message,
            eors: 'E', alignment: Alignment.center);
      }
    } on TextEmptyException catch (ex, trace) {
      showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: ex.message);
      logError(ex, trace: trace, position: 'getRefreshMiseAJourChant');
      //Navigator.of(context).pop(true);
    } on Exception catch (ex, trace) {
      showDialogProgress(show: false);
      DialogView.showAlertDialog(msg: gtr('msg_TraitementImpossible'));
      logError(ex, trace: trace, position: 'getRefreshMiseAJourChant');
    }
  }

  deleteEmailOnFirebaseAndSignOut() async {
    try {
      if (CheckPlatform().isMobileOrWeb) {
        //var firebaseAuth = FirebaseAuth.instance;
        showDialogProgress();
        //final user = firebaseAuth.currentUser!;
        //await user.delete();
        Get.find<FirebaseAuthController>().signOut();
      }
      showDialogProgress(show: false);
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
  //endregion

}

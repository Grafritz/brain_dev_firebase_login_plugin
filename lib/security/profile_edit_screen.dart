
import 'package:brain_dev_business/controllers/business_controller.dart';
import 'package:brain_dev_firebase_login/controllers/auth/firebase_auth_controller.dart';
import 'package:brain_dev_firebase_login/variables_firebase_login.dart';
import 'package:brain_dev_tools/controllers/application_controller.dart';
import 'package:brain_dev_tools/controllers/theme_controller.dart';
import 'package:brain_dev_tools/tools/layout/custom_text_form_field.dart';
import 'package:brain_dev_tools/tools/my_elevated_button.dart';
import 'package:brain_dev_tools/tools/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brain_dev_tools/tools/loading/wait_full_screen.dart';
import 'package:brain_dev_tools/tools/utils/dimensions.dart';
import 'package:brain_dev_tools/tools/utils/styles.dart';
import 'package:brain_dev_tools/views/base/profil_image.dart';
import 'package:brain_dev_tools/theme/my_app_bar_theme.dart';
//import 'package:badges/badges.dart' as badges;

class EditProfileScreen extends StatefulWidget {

  final Function? retrieveData;

  const EditProfileScreen({super.key, this.retrieveData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //region [ ATTRIBUTS ]
  ApplicationController applicationController = Get.find<ApplicationController>();
  BusinessController businessController = Get.find<BusinessController>();
  FirebaseAuthController firebaseAuthController = Get.find<FirebaseAuthController>();
  //endregion
  final formKey = GlobalKey<FormState>();

  //SessionManager prefs = SessionManager();
  final TextEditingController goutDuChefIdController = TextEditingController();
  final TextEditingController nomCompletController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController biographieController = TextEditingController();
  final TextEditingController instragramUrlController = TextEditingController();
  final TextEditingController facebookUrlController = TextEditingController();
  final TextEditingController pinterestUrlController = TextEditingController();
  final TextEditingController youtubeUrlController = TextEditingController();
  final TextEditingController localisationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initStateData();
  }

  void initStateData() async {
    await Get.find<BusinessController>().getUserConnected();
    //await businessController.getUserConnectedProfileInfo();
  }

  @override
  void dispose() {
    nomCompletController.dispose();
    emailController.dispose();
    //_passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
        return Scaffold(
          //backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          appBar: appBar(),
          body: bodyData(),
          //bottomNavigationBar: widget.widgetBannerBottomNavigation,
          bottomNavigationBar: senderGoogleAdsService.getWidgetBanner(),
        );
      }
    );
  }

  appBar() {
    return MyAppBarTheme(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      elevation: 0,
      title: 'label_profil'.tr,
      color: ColorResources.getColor(color: Colors.black)
    );
  }

  bodyData() {
    return GetBuilder<BusinessController>(builder: (userCtr) {
      // var userConnected = userCtr.userEditProfil;
      var userConnected = userCtr.userConnected;
        if (userConnected.connecterYN) {
          if (nomCompletController.text != userConnected.nomComplet) {
            nomCompletController.text = userConnected.nomComplet;
          }
          if (emailController.text != userConnected.userName) {
            emailController.text = userConnected.userName;
          }
          // if (goutDuChefIdController.text != userConnected.goutDuChefId) {
          //   goutDuChefIdController.text = userConnected.goutDuChefId;
          // }
          // if (biographieController.text != userConnected.biographie) {
          //   biographieController.text = userConnected.biographie;
          // }
          //
          // if (instragramUrlController.text != userConnected.instragramUrl) {
          //   instragramUrlController.text = userConnected.instragramUrl ?? '';
          // }
          // if (facebookUrlController.text != userConnected.facebookUrl) {
          //   facebookUrlController.text = userConnected.facebookUrl ?? '';
          // }
          // if (pinterestUrlController.text != userConnected.pinterestUrl) {
          //   pinterestUrlController.text = userConnected.pinterestUrl ?? '';
          // }
          // if (youtubeUrlController.text != userConnected.youtubeUrl) {
          //   youtubeUrlController.text = userConnected.youtubeUrl ?? '';
          // }
          // if (localisationController.text != userConnected.localisation) {
          //   localisationController.text = userConnected.localisation;
          // }
        }
        if (userConnected.connecterYN) {
          return Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  //getWidgetBanner(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: ProfilImage(photoPath: userCtr.userConnected.photoPath,
                              nomComplet: userCtr.userConnected.nomComplet,
                              width: Dimensions.IMAGE_PROFIL_BIG1_WIDTH,
                              height: Dimensions.IMAGE_PROFIL_BIG1_WIDTH,
                              userId: userCtr.userConnected.userName,
                              boxShape: BoxShape.circle, addLink: false),
                        ),


                        const SizedBox(height: 10),
                        buildInformationFields(),

                        Visibility(visible: false,
                          child: ElevatedButton.icon(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  //await userController.updateProfile();
                                }
                              },
                              style: elevatedButtonNormal(),
                              icon: const Icon(Icons.save_outlined),
                              label: Text('label_Enregistrer'.tr, style: rubikMedium)
                          ),
                        ),

                        const SizedBox(height: 55),
                        Visibility(visible: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                    onPressed: () async {
                                      await firebaseAuthController.confirmationDeleteAllDataAccount();
                                    },
                                    icon: const Icon(Icons.data_thresholding_outlined),
                                    label: Text('label_delete_all_data'.tr, style: buttonStyle,)
                                ),
                              ),
                              Expanded(
                                child: TextButton.icon(
                                    onPressed: () async {
                                      await firebaseAuthController.confirmationDeleteAccount();
                                    },
                                    icon: const Icon(Icons.delete_forever),
                                    label: Text('label_delete_profil'.tr, style: buttonStyle,)
                                ),
                              ),
                            ],
                          ),
                        ),
                        senderGoogleAdsService.getWidgetBannerLargeBanner(),
                        //getWidgetAdsMediumRectangle(),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                ],
              ),
              if( userCtr.showCircularProgress)
                const WaitFullScreen(),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }


  buildInformationFields()
  {
    //var userConnected = Get.find<BusinessController>().userConnected;
    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //textTitle('label_nom_utilisateur'.tr),
              //const SizedBox( height: 1.0, ),
              Card(
                elevation: 0.1,
                margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      // CustomTextFormField(
                      //   controller: goutDuChefIdController,
                      //   //maxLength: 150,
                      //   //labelText: 'Gout du chef ID'.tr,
                      //   hintText: 'Gout du chef ID'.tr,
                      //   prefixIcon: const Padding(
                      //     padding: EdgeInsets.only(left: 10.0, top: 10.0, right: 0),
                      //     child: Text('@', style: TextStyle(fontSize: 18,fontFamily: 'Brandon'),),
                      //   ),
                      //   // ignore: missing_return
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       String message = '${'Gout du chef ID'.tr} ${'cannot_be_empty'.tr}';
                      //       return message;
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (val){
                      //     //TODO :userController.userEditProfil.goutDuChefId=val;
                      //   },
                      // ),
                      // const SizedBox(height: 10),
                      CustomTextFormField(enabled: false,
                        initialValue: businessController.userConnected.userName,
                        label: 'label_nom_utilisateur'.tr,
                        labelText: 'label_nom_utilisateur'.tr,
                        prefixIcon: const Icon(Icons.account_circle_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          CustomTextFormField(
            controller: nomCompletController,
            //initialValue: userController.userEditProfil.nomComplet,
            //maxLength: 150,
            labelText: 'label_Full_Name'.tr,
            hintText: 'label_Full_Name'.tr,
            prefixIcon: const Icon(Icons.account_circle),
            // ignore: missing_return
            validator: (value) {
              if (value == null || value.isEmpty) {
                String message = '${'label_Full_Name'.tr} ${'cannot_be_empty'.tr}';
                return message;
              }
              return null;
            },
            onChanged: (val){
              businessController.userEditProfil.nomComplet=val;
            },
          ),

          // const SizedBox(height: 15),
          // CustomTextFormField(
          //   controller: emailController,
          //   keyboardType: TextInputType.emailAddress,
          //   labelText: 'email'.tr,
          //   hintText: 'email'.tr,
          //   prefixIcon: const Icon(Icons.email_outlined),
          //   // ignore: missing_return
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       String message = '${'email'.tr} ${'cannot_be_empty'.tr}';
          //       return message;
          //     }
          //     return null;
          //   },
          //   onChanged: (val){
          //     //userController.userEditProfil.email=val;
          //   },
          // ),

          // const SizedBox(height: 20),
          // CustomTextFormField(
          //   controller: localisationController,
          //   //initialValue: userController.userEditProfil.nomComplet,
          //   //maxLength: 150,
          //   labelText: 'label_localisation'.tr,
          //   hintText: 'label_localisation'.tr,
          //   prefixIcon: const Icon(Icons.map_outlined),
          //   // ignore: missing_return
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       String message = '${'label_localisation'.tr} ${'cannot_be_empty'.tr}';
          //       return message;
          //     }
          //     return null;
          //   },
          //   onChanged: (val){
          //     //userController.userEditProfil.localisation=val;
          //   },
          // ),

          // const SizedBox(height: 15),
          // CustomTextFormField(
          //   controller: biographieController,
          //   keyboardType: TextInputType.multiline,
          //   labelText: 'label_biographie'.tr,
          //   hintText: 'label_biographie'.tr,
          //   onChanged: (val){
          //     //TODO :userController.userEditProfil.biographie=val;
          //   },
          // ),

          const SizedBox(height: 15),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: <Widget>[
          //     textTitle('label_social_network'.tr),
          //     const SizedBox( height: 1.0, ),
          //     Card(
          //       elevation: 0.1,
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          //       child: Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Column(
          //           children: <Widget>[
          //             CustomTextFormField(
          //               controller: instragramUrlController,
          //               //maxLength: 150,
          //               labelText: 'Instagram'.tr,
          //               hintText: 'Instagram'.tr,
          //               prefixIcon: const Icon(Bootstrap.instagram),
          //               // ignore: missing_return
          //               validator: (value) {
          //                 if (value == null || value.isEmpty) {
          //                   String message = '${'Instagram'.tr} ${'cannot_be_empty'.tr}';
          //                   return message;
          //                 }
          //                 return null;
          //               },
          //               onChanged: (val){
          //                 //TODO :userController.userEditProfil.instragramUrl=val;
          //               },
          //             ),
          //
          //             const SizedBox(height: 15),
          //             CustomTextFormField(
          //               controller: facebookUrlController,
          //               //maxLength: 150,
          //               labelText: 'Facebook'.tr,
          //               hintText: 'Facebook'.tr,
          //               prefixIcon: const Icon(Bootstrap.facebook),
          //               // ignore: missing_return
          //               validator: (value) {
          //                 if (value == null || value.isEmpty) {
          //                   String message = '${'facebook'.tr} ${'cannot_be_empty'.tr}';
          //                   return message;
          //                 }
          //                 return null;
          //               },
          //               onChanged: (val){
          //                 //TODO :userController.userEditProfil.facebookUrl=val;
          //               },
          //             ),
          //
          //             const SizedBox(height: 15),
          //             CustomTextFormField(
          //               controller: pinterestUrlController,
          //               //maxLength: 150,
          //               labelText: 'Pinterest'.tr,
          //               hintText: 'Pinterest'.tr,
          //               prefixIcon: const Icon(Bootstrap.pinterest),
          //               // ignore: missing_return
          //               validator: (value) {
          //                 if (value == null || value.isEmpty) {
          //                   String message = '${'Pinterest'.tr} ${'cannot_be_empty'.tr}';
          //                   return message;
          //                 }
          //                 return null;
          //               },
          //               onChanged: (val){
          //                 //TODO :userController.userEditProfil.pinterestUrl=val;
          //               },
          //             ),
          //
          //             const SizedBox(height: 15),
          //             CustomTextFormField(
          //               controller: youtubeUrlController,
          //               //maxLength: 150,
          //               labelText: 'Youtube'.tr,
          //               hintText: 'Youtube'.tr,
          //               prefixIcon: const Icon(Bootstrap.youtube),
          //               // ignore: missing_return
          //               validator: (value) {
          //                 if (value == null || value.isEmpty) {
          //                   String message = '${'Youtube'.tr} ${'cannot_be_empty'.tr}';
          //                   return message;
          //                 }
          //                 return null;
          //               },
          //               onChanged: (val){
          //                 //TODO :userController.userEditProfil.youtubeUrl=val;
          //               },
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),

          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text('label_dateCreated'.tr),
                  subtitle: Text(businessController.userConnected.dateCreatedDisplay),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('label_LastLogin'.tr),
                  subtitle: Text(businessController.userConnected.lastLoginDisplay),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

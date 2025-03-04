//import 'package:brain_dev_business/config/routes/route_helper_business_auth.dart';
import 'package:brain_dev_firebase_login/config/routes/route_helper.dart';
// import 'package:brain_dev_tools/config/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageLoginPage extends StatelessWidget {
  const MessageLoginPage({ super.key, this.redirect });
  final String? redirect;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        RouteHelperAuth.navLoginPage(redirect: redirect);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Center(
            //   child: Image.asset(Constant.assetsLoginPath, width: MediaQuery.of(context).size.width-100 ),
            // ),
            const SizedBox(height: 30),
            Text(
              'login_or_create_account'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                wordSpacing: 0,
                fontFamily: 'Brandon',
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 30),
            // DefaultCustomButton(
            //   text: 'login_or_create_account'.tr,
            //   onPressed: () => Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => const LoginPage()),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' show Platform;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tapastop/utils/globals.dart';
import 'package:tapastop/utils/navigator.dart';
import 'loginScreen.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPassScreen> {
  final RegExp _emailRegEXp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  String _email = "";


  Widget _buildEmailField() {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery
                .of(context)
                .size
                .height * 0.02),
        child: SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.08,
            child: TextFormField(
              onChanged: (email) {
                _email = email;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: TextStyle(
                  fontSize: MediaQuery
                      .of(context)
                      .size
                      .width * 0.0334
              ),
              validator: (email) =>
              !_emailRegEXp.hasMatch(email ?? "") ? AppLocalizations.of(
                  context)!.invMail : null,
              decoration: InputDecoration(
                  helperText: " ",
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(
                      fontSize: MediaQuery
                          .of(context)
                          .size
                          .width * 0.0334
                  ),
                  hintText: AppLocalizations.of(context)!.email
              ),
            )
        )
    );
  }

  Widget _title() {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery
                .of(context)
                .size
                .height * 0.01,
            vertical: MediaQuery
                .of(context)
                .size
                .height * 0.01),
        child: Text(AppLocalizations.of(context)!.findAcc,
            style: TextStyle(
                color: Theme
                    .of(context)
                    .primaryColor, fontSize: MediaQuery
                .of(context)
                .size
                .width * 0.06, fontWeight: FontWeight.w400)));
  }

  Widget _buildSendEmail() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: () => sendEmail(),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme
                    .of(context)
                    .primaryColorDark,
                padding:
                EdgeInsets.symmetric(vertical: MediaQuery
                    .of(context)
                    .size
                    .height * 0.001)),
            child: Text(AppLocalizations.of(context)!.sendMail)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.80,
              child: Column(children: [
                Logo.build(context),
                _title(),
                Text(AppLocalizations.of(context)!.enterLinkedMail),
                _buildEmailField(),
                _buildSendEmail()
              ])),
        ));
  }

  void toast(String text) {
    Fluttertoast.showToast(msg: text, backgroundColor: Colors.grey);
  }

  void sendEmail() {
    FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    String title = AppLocalizations.of(context)!.mailSent;
    String body = "${AppLocalizations.of(context)!.mailSentWL2} $_email";
    goback() => Navigator.pushAndRemoveUntil(
        context, MyNavigator.createRoute(const LoginScreen()), (
        Route<dynamic> route) => false);
    FocusScope.of(context).unfocus();
    toast(AppLocalizations.of(context)!.smtWW);
    AndroidSimpleAlertDialog.showAndroidDialog(
        context, title, Text(body), () => goback());
  }
}

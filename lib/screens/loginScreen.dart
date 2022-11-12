import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tapastop/screens/signupScreen.dart';
import 'package:tapastop/utils/globals.dart';
import 'package:tapastop/screens/forgotpassword.dart';

import '../utils/navigator.dart';
import 'homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}


class LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  String _username = "testuser@gmail.com";
  String _password = "123456";

  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: _username,
      onChanged: (username) {
        _username = username;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (username) => !Global.emailRegEXp.hasMatch(username ?? "") &&
          !Global.usernameRegExp.hasMatch(username ?? "")
          ? AppLocalizations.of(context)!.invUser
          : null,
      decoration: InputDecoration(
          border: const UnderlineInputBorder(), hintText: AppLocalizations.of(context)!.enterUoE),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      initialValue: _password,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (password) {
        _password = password;
      },
      validator: (pass) => pass!.length < 6 ? AppLocalizations.of(context)!.pass6 : null,
      obscureText: _obscureText,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: _obscureText ? Colors.grey : Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() => _obscureText = !_obscureText);
            },
          ),
          border: const UnderlineInputBorder(),
          hintText: AppLocalizations.of(context)!.enterPass),
    );
  }

  Widget _buildForm() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
              child: _buildUsernameField(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.01),
              child: _buildPasswordField(),
            ),
          ],
        ));
  }

  Widget _buildSignIn() {
    final loginVM = Provider.of<LogSignInVM>(context);
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.043,
        // decoration: BoxDecoration(gradient: Utils.gradient),
        child: ElevatedButton(
            onPressed: () async {
              LogState state = await loginVM.mailPassLogin(_username, _password);
              if (true//state == LogState.success
              ) {
                Navigator.pushAndRemoveUntil(
                    context, MyNavigator.createRoute(HomeScreen()), (
                    Route<dynamic> route) => false);
              }
              },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, double.infinity), backgroundColor:Theme.of(context).primaryColorLight,
              shadowColor: Colors.transparent,
            ),
            child: FittedBox(
              // En este no pero en *2 si que se salía en algunos dispositivos
              child: Text(AppLocalizations.of(context)!.signIn),
            )));
  }

  Widget _buildSignUp() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.height * 0.04,
        child: TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA72886), shape: ContinuousRectangleBorder(
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 3)),
            ),
            child: FittedBox(
              // *2
              child: Text(AppLocalizations.of(context)!.signUp),
            )));
  }

  Widget _buildLogButtonBar() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.009),
        width: double.infinity,
        child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              _buildSignIn(),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02)),
              _buildSignUp(),
            ])));
  }

  Widget _buildForgotPass() {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.01),
            child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: TextButton(
                    style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
                    child: Text(AppLocalizations.of(context)!.forgotPass),
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const ForgotPassScreen()));
                    }))));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColorDark));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Column(children: [
                Logo.build(context),
                _buildForm(),
                _buildLogButtonBar(),
                _buildForgotPass(),
              ])),
        ));
  }
}

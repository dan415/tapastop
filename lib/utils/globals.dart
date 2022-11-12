import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../firebase_operations/authenticator.dart';

class Global{

  static RegExp usernameRegExp = RegExp(r"^[a-zA-Z0-9][\\w.]+[a-zA-Z0-9]\$");
  static RegExp nombreRegExp = RegExp(r"[a-zA-Z0-9]*");
  static RegExp phoneRegExp = RegExp(r"[0-9]");
  static RegExp dateRegExp = RegExp(r"^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$");
  static RegExp emailRegEXp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");


}
class Paddings {
  static Widget verticalPadding({double size = 15}) => Container(
    padding: EdgeInsets.only(left: size),
  );

  static Widget horizontalPadding({double size = 60}) => Container(
    padding: EdgeInsets.only(top: size),
  );

  static EdgeInsets containerPadding({required Size screenSize, double topMultiplier = 0.05, double bottomMultiplier = 0.01, leftMultiplier = 0.05, rightMultiplier = 0.05}){
    return EdgeInsets.fromLTRB(screenSize.width * leftMultiplier, screenSize.height * topMultiplier, screenSize.width * rightMultiplier, screenSize.height * bottomMultiplier);
  }
}

class Logo {
  static Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.20,
          MediaQuery.of(context).size.height * 0.05,
          MediaQuery.of(context).size.width * 0.20,
          MediaQuery.of(context).size.height * 0.1),
      child: const Text("TapasTop"),
    );
  }
}


class AndroidSimpleAlertDialog {
  static Widget _buildAlertDialog(
      BuildContext context, String title, Widget? body, VoidCallback action) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: Theme.of(context).primaryColorDark)),
      content: body,
      actions: [
        TextButton(onPressed: action, child: Text(AppLocalizations.of(context)!.accept)),
      ],
    );
  }

  static Future showAndroidDialog(
      BuildContext context, String title, Widget? body, VoidCallback action) async {
    return showDialog(
      context: context,
      builder: (_) => _buildAlertDialog(context, title, body, action),
    );
  }



}

enum LogState { success, userNotFound, wrongPass, undefined, failure }

class LogSignInVM extends ChangeNotifier {
  // Logs user in  with email and password
  Future<LogState> mailPassLogin(String email, String password) async {
    try {
      await FirebaseAuthenticator().login(email, password);
      return LogState.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return LogState.userNotFound;
      if (e.code == 'wrong-password') return LogState.wrongPass;
    }
    notifyListeners();
    return LogState.undefined;
  }
}

class PasswordAlertDialog {
  static Future show(BuildContext context, String newPass) async {
    return _showAndroidDialog(context, newPass);
  }

  static Future _showIOSDialog(BuildContext context, String newPass) async {
    return showCupertinoDialog(context: context, builder: (_) => _PassAlertDialog(newPass));
  }

  static Future _showAndroidDialog(BuildContext context, String newPass) async {
    return showDialog(
      context: context,
      builder: (_) => _PassAlertDialog(newPass),
    );
  }
}


class _PassAlertDialog extends StatefulWidget {
  final String newPassword;

  _PassAlertDialog(this.newPassword);

  @override
  _PassAlertDialogState createState() => _PassAlertDialogState();
}

class _PassAlertDialogState extends State<_PassAlertDialog> {
  bool _obscureText = true;

  void _action() {
    Navigator.pop(context);
    //Navigator.popAndPushNamed(context, "/account");
  }

  // String _password = "";
  // late String _newPassword;
  // @override
  // void initState() {
  //   super.initState();
  //   _newPassword = widget.newPassword;
  // }

  Widget _buildPassField() {
    return Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
        height: MediaQuery.of(context).size.height * 0.08,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (password) {
            // _password = password;
          },
          style: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
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
              helperText: " ",
              border: const OutlineInputBorder(),
              hintStyle: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
              hintText: AppLocalizations.of(context)!.enterPass),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: Text(AppLocalizations.of(context)!.enterCurPass,
          style: TextStyle(color: Theme.of(context).primaryColorDark)),
      content: _buildPassField(),
      actions: [
        TextButton(
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(context)),
        TextButton(
            child: Text(AppLocalizations.of(context)!.accept,
                style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () => _action()),
      ],
    );
  }
}


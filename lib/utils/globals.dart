import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../firebase_operations/authenticator.dart';

class Global{

  static RegExp usernameRegExp = RegExp(r"^[a-zA-Z0-9][\\w.]+[a-zA-Z0-9]\$");
  static RegExp nombreRegExp = RegExp(r"[a-zA-Z0-9]*");
  static RegExp phoneRegExp = RegExp(r"[0-9]");
  static RegExp dateRegExp = RegExp(r"^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$");
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

  static Future _showIOSDialog(BuildContext context) async {
    return showCupertinoDialog(context: context, builder: (_) => _PassAlertDialog());
  }

  static Future _showAndroidDialog(BuildContext context, String newPass) async {
    return showDialog(
      context: context,
      builder: (_) => _PassAlertDialog(),
    );
  }
}


class _PassAlertDialog extends StatefulWidget {

  const _PassAlertDialog();

  @override
  _PassAlertDialogState createState() => _PassAlertDialogState();
}

class _PassAlertDialogState extends State<_PassAlertDialog> {
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  String oldpass = "";
  String newpass = "";
  FirebaseAuthenticator auth = FirebaseAuthenticator();

  Future<void> _action() async {
    if(oldpass != null && newpass != null && oldpass != newpass){
      User? user = FirebaseAuth.instance.currentUser!;
      user.reauthenticateWithCredential(EmailAuthProvider.credential(email: user.email!, password: oldpass)).then((value) => {
        print(value),
        user.updatePassword(newpass).then((value) => {
          Fluttertoast.showToast(msg: "Contraseña cambiada correctamente"),
          Navigator.pop(context)
        })
      }).onError((error, stackTrace) => {
        Fluttertoast.showToast(msg: "Contraseña incorrecta")
      }).catchError((error) => {
        Fluttertoast.showToast(msg: error.toString())
      });
    }
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
        height: MediaQuery.of(context).size.height * 0.2,
        child: Column(
          children: [
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (password) {
                oldpass = password;
              },
              style: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
              validator: (pass) => pass!.length < 6 ? AppLocalizations.of(context)!.pass6 : null,
              obscureText: _obscureText1,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: _obscureText1 ? Colors.grey : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _obscureText1 = !_obscureText1);
                    },
                  ),
                  helperText: " ",
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
                  hintText: AppLocalizations.of(context)!.enterPass),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (password) {
                newpass = password;
              },
              style: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
              validator: (pass) => pass!.length < 6 ? AppLocalizations.of(context)!.pass6 : null,
              obscureText: _obscureText2,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: _obscureText2 ? Colors.grey : Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() => _obscureText2 = !_obscureText2);
                    },
                  ),
                  helperText: " ",
                  border: const OutlineInputBorder(),
                  hintStyle: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
                  hintText: "Introduce la nueva contraseña"),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: Text("Introduce tu contraseña actual y nueva contraseña",
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


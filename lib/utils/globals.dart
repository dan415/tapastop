import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Global{

  static RegExp usernameRegExp = RegExp(r"^[a-zA-Z0-9][\\w.]+[a-zA-Z0-9]\$");
  static RegExp phoneRegExp = RegExp(r"^[0-9]+\$");
  static RegExp dateRegExp = RegExp(r"^[0-9]{2}/[0-9]{2}/[0-9]{4}\$");
  static RegExp emailRegEXp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");


}


class Logo {
  static Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.20,
          MediaQuery.of(context).size.height * 0.05,
          MediaQuery.of(context).size.width * 0.20,
          MediaQuery.of(context).size.height * 0.1),
      child: Image.asset('res/icons/Logo-horizontal-degradado.png'),
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
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

import '../model/userModel.dart';
import '../model/userViewModel.dart';
import '../utils/globals.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AccountPage(),
    );
  }
}

enum Editing { none, username, password, birthday, bio, name, phone, country }

class _AccountPage extends StatefulWidget {
  State<StatefulWidget> createState() => _AccountState();
}

class _AccountState extends State<_AccountPage> {
  DocumentSnapshot? snapshot;
  Editing editing = Editing.none;
  String _displayNameEdit = "";
  String _bioEdit = "";
  String _usernameEdit = "";
  String _bdayEdit = ""; // TODO: Add send btn to bday edit tile
  String _phoneEdit = "";
  String _birthday = "";
  String _phone = "";
  String _bio = "";

  @override
  void initState() {
    super.initState();
    _setValues();
  }

  void _loadSnapshot() {
    Provider.of<UserVM>(context, listen: false).loadUser(FirebaseAuth.instance.currentUser!.uid);
  }

  void _setValues() {
    try {
      _phone = snapshot?.get("phone");
    } catch (e) {}
    try {
      _bio = snapshot?.get("bio");
    } catch (e) {}
    try {
      _birthday = snapshot?.get("birthday");
    } catch (e) {}
  }

  void submit(Editing edit) {
    if (editing == Editing.password) {
      FocusScope.of(context).unfocus();
      PasswordAlertDialog.show(context, "").then((_) {
        FocusScope.of(context).unfocus();
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.passChanged, backgroundColor: Colors.grey);
      });
    }
    editing = Editing.none;
    setState(() {});
  }

  Widget _title() {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.acc,
          style: const TextStyle(color: Colors.black),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: _screenWidth * 0.02)),
        Icon(
          Icons.person,
          color: Theme.of(context).primaryColorDark,
        )
      ],
    );
  }

  Widget _datePick() {
    return SizedBox(
        width: double.infinity,
        child: Column(children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime(1900),
                  onDateTimeChanged: (DateTime newDateTime) {
                    _bdayEdit = newDateTime.toString();
                  },
                ),
              )),
          ButtonBar(children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  submit(editing);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                child: Text(AppLocalizations.of(context)!.accept,
                    style: const TextStyle(color: Colors.white)))
          ])
        ]));
  }



  // Widget _passField() {
  //   return TextFormField(
  //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //     // onChanged: (password) { // Change this to a btn to reset pass
  //     //   _password = password;
  //     // },
  //     style: TextStyle(fontSize: 14),
  //     validator: (pass) => pass!.length < 6 ? '${AppLocalizations.of(context)!.pass6}' : null,
  //     obscureText: _obscureText,
  //     decoration: InputDecoration(
  //         suffixIcon: IconButton(
  //           icon: Icon(
  //             Icons.remove_red_eye,
  //             color: _obscureText ? Colors.grey : Theme.of(context).primaryColor,
  //           ),
  //           onPressed: () {
  //             _obscureText = !_obscureText;
  //             setState(() {});
  //           },
  //         ),
  //         helperText: " ",
  //         hintStyle: TextStyle(fontSize: 14),
  //         hintText: '${AppLocalizations.of(context)!.enterPass}'),
  //   );
  // }

  Future<void> _upload(DocumentFields field, String value) async {
    if (value != "") await Provider.of<UserVM>(context, listen: false).updateUserDoc(field, value);
  }

  Widget _body() {
    return ListView(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.profile,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: editing == Editing.name
              ? TextFormField(
              initialValue: "${snapshot?.get("displayName") ?? ""}",
              onChanged: (change) => _displayNameEdit = change)
              : Text(AppLocalizations.of(context)!.cName),
          subtitle: editing == Editing.name
              ? null
              : SelectableText("${snapshot?.get("displayName") ?? ""}"),
          trailing: editing == Editing.name
              ? IconButton(
              onPressed: () async {
                _upload(DocumentFields.displayName, _displayNameEdit)
                    .whenComplete(() => _loadSnapshot());
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).accentColor)
              : const Icon(Icons.drive_file_rename_outline),
          onTap: () {
            editing = Editing.name;
            setState(() {});
          },
        ),
        ListTile(
          title: editing == Editing.bio
              ? TextFormField(
            initialValue: _bio,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onChanged: (change) => _bioEdit = change,
          )
              : Text(AppLocalizations.of(context)!.cBio),
          subtitle: editing == Editing.bio ? null : SelectableText("$_bio"),
          trailing: editing == Editing.bio
              ? IconButton(
              onPressed: () {
                _upload(DocumentFields.bio, _bioEdit).whenComplete(() => _loadSnapshot());
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.secondary)
              : const Icon(Icons.edit),
          onTap: () {
            editing = Editing.bio;
            setState(() {});
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.personal,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          title: editing == Editing.username
              ? TextFormField(
              initialValue: "${snapshot?.get("username") ?? ""}",
              onChanged: (change) => _usernameEdit = change)
              : Text(AppLocalizations.of(context)!.cUser),
          subtitle: editing == Editing.username
              ? null
              : SelectableText("${snapshot?.get("username") ?? ""}"),
          trailing: editing == Editing.username
              ? IconButton(
              onPressed: () async {
                DataSnapshot? snapshot =
                await FirebaseDatabase.instance.reference().child("usernames").get();
                String data = snapshot.value.toString().replaceAll("}", ",");
                if (_usernameEdit != "" &&
                    !_usernameEdit.contains(" ") &&
                    !data.contains("$_usernameEdit,")) {
                  await Provider.of<UserVM>(context, listen: false)
                      .updateUsername(_usernameEdit)
                      .whenComplete(() => _loadSnapshot());
                }
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).accentColor)
              : const Icon(Icons.alternate_email),
          onTap: () {
            editing = Editing.username;
            setState(() {});
          },
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.cPass),
          trailing: const Icon(CupertinoIcons.asterisk_circle_fill),
          onTap: () {
            editing = Editing.password;
            setState(() {});
          },
        ),
        ListTile(
          title: ((editing == Editing.birthday) && Platform.isAndroid)
              ? DateTimePicker(
              initialDate: DateTime.now(),
              type: DateTimePickerType.date,
              dateLabelText: AppLocalizations.of(context)!.selDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onFieldSubmitted: (value){
              },

              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _bdayEdit = value;
                    _upload(DocumentFields.birthday, value);
                  });
                }
              })
              : Text(AppLocalizations.of(context)!.cBirthday),
          subtitle: editing == Editing.birthday ? null : SelectableText(_birthday),
          trailing: const Icon(Icons.cake),
          onTap: () {
            editing = Editing.birthday;
            if (Platform.isIOS) {
              showModalBottomSheet<dynamic>(
                  isDismissible: false,
                  isScrollControlled: true,
                  enableDrag: false,
                  context: context,
                  builder: (BuildContext context) => _datePick());
            }
            setState(() {});
          },
        ),
        ListTile(
          title: editing == Editing.phone
              ? TextFormField(
              initialValue: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 9,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (change) => _phoneEdit = change,
              validator: (pass) =>
              pass!.length != 9 ? AppLocalizations.of(context)!.invPhone : null)
              : Text(AppLocalizations.of(context)!.cPhone),
          subtitle: editing == Editing.phone ? null : SelectableText(_phone),
          trailing: editing == Editing.phone
              ? IconButton(
              onPressed: () => Provider.of<UserVM>(context, listen: false)
                  .updateUserDoc(DocumentFields.phone, _phoneEdit),
              icon: const Icon(Icons.send),
              color: Theme.of(context).accentColor)
              : const Icon(Icons.phone),
          onTap: () {
            editing = Editing.phone;
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    snapshot = Provider.of<UserVM>(context).userResponse.data;
    _setValues();
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            title: _title(),
            floating: true,
          ),
        ],
        body: _body());
  }
}

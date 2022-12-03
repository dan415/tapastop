import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';

import '../firebase_operations/authenticator.dart';
import '../firebase_operations/databaseAPI.dart';
import '../model/userModel.dart';
import '../model/userViewModel.dart';
import '../utils/globals.dart';

class AccountPage extends StatefulWidget {
  _ProviderWidgetState createState() => _ProviderWidgetState();
}

class _ProviderWidgetState extends State
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: UserVM(),
      child: Scaffold(body: _AccountPage()),
    );
  }
}

enum Editing { none, username, surname, password, birthday, bio, name, phone, country }

class _AccountPage extends StatefulWidget {
  State<StatefulWidget> createState() => _AccountState();
}

class _AccountState extends State<_AccountPage> {
  DocumentSnapshot? snapshot;
  Editing editing = Editing.none;
  String _displayNameEdit = "";
  String _bioEdit = "";
  String _surname = "";
  String _localidad  = "";
  String _bdayEdit = ""; // TODO: Add send btn to bday edit tile
  String _phoneEdit = "";
  String _birthday = "";
  String _bio = "";
  Database db = Database();
  FirebaseAuthenticator auth = FirebaseAuthenticator();
  String uid =  FirebaseAuth.instance.currentUser!.uid;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
  }



  void submit(Editing edit) {
    if (editing == Editing.password) {
      FocusScope.of(context).unfocus();
      PasswordAlertDialog.show(context, "").then((_) {
        FocusScope.of(context).unfocus();
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
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

  void toast(String text) {
    Fluttertoast.showToast(msg: text, backgroundColor: Colors.grey);
  }


  Widget _passField() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // onChanged: (password) { // Change this to a btn to reset pass
      //   _password = password;
      // },
      style: const TextStyle(fontSize: 14),
      validator: (pass) => pass!.length < 6 ? AppLocalizations.of(context)!.pass6 : null,
      obscureText: _obscureText,
      decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: _obscureText ? Colors.grey : Theme.of(context).primaryColor,
            ),
            onPressed: () {
              _obscureText = !_obscureText;
              setState(() {});
            },
          ),
          helperText: " ",
          hintStyle: const TextStyle(fontSize: 14),
          hintText: AppLocalizations.of(context)!.enterPass),
    );
  }

  Widget _body() {
    return ListView(
      children: [
        Material(child:
        ListTile(
          title: Text(AppLocalizations.of(context)!.profile,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        )),
        Material(child:
        ListTile(
          title: editing == Editing.name
              ? TextFormField(
              initialValue: "",
              onChanged: (change) => _displayNameEdit = change)
              : Text(AppLocalizations.of(context)!.cName),
          subtitle: editing == Editing.name
              ? null
              : const SelectableText(""),
          trailing: editing == Editing.name
              ? IconButton(
              onPressed: () async {
                print(uid);
                if (uid != null) {
                  db?.changeUserField(uid!, "nombre", _displayNameEdit);
                  submit(editing);
                }
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.secondary)
              : const Icon(Icons.drive_file_rename_outline),
          onTap: () {
            editing = Editing.name;
            setState(() {});
          },
        )),

        Material(child:
        ListTile(
          title: editing == Editing.surname
              ? TextFormField(
              initialValue: "",
              onChanged: (change) => _surname = change)
              : const Text("Cambiar Apellido"),
          subtitle: editing == Editing.surname
              ? null
              : const SelectableText(""),
          trailing: editing == Editing.surname
              ? IconButton(
              onPressed: () async {
                print(uid);
                if (uid != null) {
                  db.changeUserField(uid!, "apellido", _surname);
                  submit(editing);
                }
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.secondary)
              : const Icon(Icons.drive_file_rename_outline),
          onTap: () {
            editing = Editing.surname;
            setState(() {});
          },
        )),
        Material(child:
        ListTile(
          title: editing == Editing.country
              ? TextFormField(
              initialValue: "",
              onChanged: (change) => _localidad = change)
              : const Text("Cambiar localidad"),
          subtitle: editing == Editing.country
              ? null
              : const SelectableText(""),
          trailing: editing == Editing.country
              ? IconButton(
              onPressed: () async {
                if (uid != null) {
                  db.changeUserField(uid, "localidad", _localidad);
                  submit(editing);
                }
              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.secondary)
              : const Icon(Icons.drive_file_rename_outline),
          onTap: () {
            editing = Editing.country;
            setState(() {});
          },
        )),
        Material(child:
        ListTile(
          title: editing == Editing.bio
              ? TextFormField(
            initialValue: _bio,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onChanged: (change) => _bioEdit = change,
          )
              : Text(AppLocalizations.of(context)!.cBio),
          subtitle: editing == Editing.bio ? null : SelectableText(_bio),
          trailing: editing == Editing.bio
              ? IconButton(
              onPressed: () {
               if (uid != null) {
                  db?.changeUserField(uid!, "presentacion", _bioEdit);
                  submit(editing);
                }

              },
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.secondary)
              : const Icon(Icons.edit),
          onTap: () {
            editing = Editing.bio;
            setState(() {});
          },
        )),
        Material(child:
        ListTile(
          title: Text(AppLocalizations.of(context)!.personal,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        )),
        Material(child:
        ListTile(
          title: Text(AppLocalizations.of(context)!.cPass),
          trailing: const Icon(CupertinoIcons.asterisk_circle_fill),
          onTap: () {
            // RECOVER CARD FROM PARTYRLA
            editing = Editing.password;
            setState(() {submit(editing);});
          },
        )),
        Material(child:
        ListTile(
          title: ((editing == Editing.birthday) && Platform.isAndroid)
              ? DateTimePicker(
              initialDate: DateTime.now(),
              validator: (date) {
                if (date != null) {
                  if (date.isNotEmpty) {
                    DateTime birthday = DateTime.parse(date);
                    DateTime today = DateTime.now();
                    int age = today.year - birthday.year;
                    if (today.month < birthday.month ||
                        (today.month == birthday.month &&
                            today.day < birthday.day)) {
                      age--;
                      return age < 18
                          ? AppLocalizations.of(context)!.invAge
                          : null;
                    }
                  }
                }
                return null;
              },
              type: DateTimePickerType.date,
              dateLabelText: AppLocalizations.of(context)!.selDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onFieldSubmitted: (value){

              },

              onChanged: (value) {
                if (value.isNotEmpty){
                  DateTime birthday = DateTime.parse(value);
                  DateTime today = DateTime.now();
                  int age = today.year - birthday.year;
                  if (today.month < birthday.month ||
                      (today.month == birthday.month &&
                          today.day < birthday.day)) {
                    age--;
                  }
                  if (age < 18) {
                    _bdayEdit = "";
                    toast(AppLocalizations.of(context)!.invAge);
                  } else {
                    setState(() {
                      print(value);
                      _bdayEdit = value;
                      db.changeUserField(uid, "edad", _bdayEdit);
                      submit(editing);
                    });
                  }
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
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            expandedHeight: 10,
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

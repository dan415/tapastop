import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tapastop/firebase_operations/authenticator.dart';
import 'package:tapastop/firebase_operations/databaseAPI.dart';

import '../utils/globals.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpPageState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: _SignUpScreen(),
    );
  }
}

class _SignUpScreen extends StatefulWidget {
  const _SignUpScreen({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  String username = "";
  String nombre = "";
  String apellidos = "";
  String telefono = "";
  String correo = "";
  String _password = "";
  String _dateTime = "1980-01-01";
  bool _obscureText = true;
  bool validated_age = false;
  FirebaseAuthenticator _auth = FirebaseAuthenticator();
  Database _db = Database();

  Widget _buildUsernameField() {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
            child: TextFormField(
              onChanged: (username) {
                username = username;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (username) =>
                  !Global.usernameRegExp.hasMatch(username!)
                      ? AppLocalizations.of(context)!.invUser
                      : null,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.0334),
              decoration: InputDecoration(
                  helperText: " ",
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintStyle: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.0334),
                  hintText: AppLocalizations.of(context)!.username),
            )));
  }

  void toast(String text) {
    Fluttertoast.showToast(msg: text, backgroundColor: Colors.grey);
  }

  Widget _title() {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.01,
            vertical: MediaQuery.of(context).size.height * 0.01),
        child: Text(AppLocalizations.of(context)!.chooseUser,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: MediaQuery.of(context).size.width * 0.057,
                fontWeight: FontWeight.w400)));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent));
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
              const SliverAppBar(
                pinned: true,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                backgroundColor: Colors.cyanAccent,
                expandedHeight: 0,
                title: Text("TapasTop", style: TextStyle(color: Colors.black)),
                floating: false,
                flexibleSpace: FlexibleSpaceBar(collapseMode: CollapseMode.pin),
              ),
            ],
        body: ListView(children: [
          Material(
              child: ListTile(
            title: Text(AppLocalizations.of(context)!.addBday,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          Material(
              child: ListTile(
                  title: TextFormField(
            initialValue: _dateTime,
            onChanged: (dateTime) {
              _dateTime = dateTime;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (dateTime) => !Global.dateRegExp.hasMatch(dateTime ?? "")
                ? AppLocalizations.of(context)!.invDate
                : null,
            decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: AppLocalizations.of(context)!.enterUoE),
          ))),
          Material(
            child: ListTile(
              title: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(AppLocalizations.of(context)!.verify,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  onPressed: () {
                    // Check if older than 18
                    DateTime birthday = DateTime.parse(_dateTime);
                    DateTime today = DateTime.now();
                    int age = today.year - birthday.year;
                    if (today.month < birthday.month ||
                        (today.month == birthday.month &&
                            today.day < birthday.day)) {
                      age--;
                    }
                    if (age >= 18) {
                      validated_age = true;
                    } else {
                      validated_age = false;
                    }
                  }),
            ),
          ),
          Material(
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.chooseUser,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Material(
            child: ListTile(
              title: TextFormField(
                initialValue: username,
                onChanged: (user) {
                  username = user;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (x) => !Global.usernameRegExp.hasMatch(x ?? "")
                    ? AppLocalizations.of(context)!.invUser
                    : null,
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: AppLocalizations.of(context)!.enterUoE),
              ),
            ),
          ),
          Material(
            child: ListTile(
              title: Text(AppLocalizations.of(context)!.choosePass,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Material(
              child: ListTile(
                  title: TextFormField(
                      initialValue: "",
                      obscureText: _obscureText,
                      onChanged: (pwd) {
                        _password = pwd;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (u) => (u == null || u.length < 6)
                          ? AppLocalizations.of(context)!.pass6
                          : null,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: _obscureText
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() => _obscureText = !_obscureText);
                            },
                          ),
                          helperText: " ",
                          border: const OutlineInputBorder(),
                          hintStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.0334),
                          hintText: AppLocalizations.of(context)!.enterPass)))),
          Material(
              child: ListTile(
            title: Text(AppLocalizations.of(context)!.enterNombre,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          Material(
              child: ListTile(
                  title: TextFormField(
            initialValue: nombre,
            onChanged: (user) {
              nombre = user;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (x) => !Global.nombreRegExp.hasMatch(x ?? "")
                ? AppLocalizations.of(context)!.invtext
                : null,
          ))),
          Material(
              child: ListTile(
            title: Text(AppLocalizations.of(context)!.capellidos,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          Material(
              child: ListTile(
                  title: TextFormField(
            initialValue: apellidos,
            onChanged: (user) {
              apellidos = user;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (x) => !Global.nombreRegExp.hasMatch(x ?? "")
                ? AppLocalizations.of(context)!.invtext
                : null,
          ))),
          Material(
              child: ListTile(
            title: Text(AppLocalizations.of(context)!.enterEmail,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          Material(
              child: ListTile(
                  title: TextFormField(
            initialValue: correo,
            onChanged: (user) {
              correo = user;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (x) => !Global.emailRegEXp.hasMatch(x ?? "")
                ? AppLocalizations.of(context)!.invMail
                : null,
          ))),
          Material(
              child: ListTile(
            title: Text(AppLocalizations.of(context)!.enterPhone,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
          Material(
              child: ListTile(
                  title: TextFormField(
                      initialValue: telefono,
                      onChanged: (tele) {
                        telefono = tele;
                        print(!Global.phoneRegExp.hasMatch(telefono ?? ""));
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (t) => !Global.phoneRegExp.hasMatch(t ?? "")
                          ? AppLocalizations.of(context)!.invPhone
                          : null))),
          Material(
            child: ListTile(
              title: MaterialButton(
                color: Theme.of(context).primaryColor,
                child: Text(AppLocalizations.of(context)!.signUp,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () async {
                  if (!validated_age) {
                    toast(AppLocalizations.of(context)!.invAge);
                  } else {
                    // Añadir usuario a la base de datos
                    String uid = await _auth.createUser(correo, _password);
                    _db.addUser(uid, nombre, apellidos, null, _dateTime, null);
                  }
                },
              ),
            ),
          ),
          Container(
            height: 200,
            color: Colors.white,
          )
        ]));
  }
}

    /*return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width*0.80,
              child: Column(
                  children: [
                    Logo.build(context),
                    _title(),
                    Text('${AppLocalizations.of(context)!.youCanChange}'),
                    _buildUsernameField(),
                  ])
          ),
        ));
  }

*/


import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/globals.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

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
  String _dateTime = "01/01/1970";
  bool _obscureText = true;

  Widget _buildUsernameField(){
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02),
        child: SizedBox(
            height: MediaQuery.of(context).size.height*0.08,
            child:TextFormField(
              onChanged: (username) {username = username;},
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (username) =>
              !Global.usernameRegExp.hasMatch(username!) ? AppLocalizations.of(context)!.invUser : null,
              style: TextStyle(
                  fontSize:  MediaQuery.of(context).size.width*0.0334
              ),
              decoration: InputDecoration(
                  helperText: " ",
                  border: const OutlineInputBorder(),
                  isDense: true,
                  hintStyle: TextStyle(
                      fontSize:  MediaQuery.of(context).size.width*0.0334
                  ),
                  hintText: AppLocalizations.of(context)!.username
              ),
            )
        )
    );
  }

  Widget _title(){
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * 0.01,
            vertical: MediaQuery.of(context).size.height * 0.01),
        child: Text(AppLocalizations.of(context)!.chooseUser,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize:  MediaQuery.of(context).size.width*0.057,
                fontWeight: FontWeight.w400
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            pinned: true,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            title: Logo.build(context),
            floating: true,
          ),
        ],

        body: ListView(
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.addBday,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
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
                    border: const UnderlineInputBorder(), hintText: AppLocalizations.of(context)!.enterUoE),
              )),
              ListTile(
                title: MaterialButton(
                  child: Text(AppLocalizations.of(context)!.verify,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    //TODO VALIDAR FECHA
                  }
                 )
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.chooseUser,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
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
                        border: const UnderlineInputBorder(), hintText: AppLocalizations.of(context)!.enterUoE),
                  )),
              ListTile(
                title: Text(AppLocalizations.of(context)!.choosePass,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
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
                            color: _obscureText ? Colors.grey : Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        ),
                        helperText: " ",
                        border: const OutlineInputBorder(),
                        hintStyle: TextStyle(fontSize:  MediaQuery.of(context).size.width*0.0334),
                        hintText: AppLocalizations.of(context)!.enterPass)
                  )),
              ListTile(
                title: Text(AppLocalizations.of(context)!.cName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  title: TextFormField(
                    initialValue: nombre,
                    onChanged: (user) {
                      nombre = user;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (x) => !Global.usernameRegExp.hasMatch(x ?? "")
                        ? AppLocalizations.of(context)!.invtext
                        : null,
                     )),
              ListTile(
                title: Text(AppLocalizations.of(context)!.capellidos,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  title: TextFormField(
                    initialValue: apellidos,
                    onChanged: (user) {
                      apellidos = user;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (x) => !Global.usernameRegExp.hasMatch(x ?? "")
                        ? AppLocalizations.of(context)!.invtext
                        : null,
                  )),
              ListTile(
                title: Text(AppLocalizations.of(context)!.enterEmail,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  title: TextFormField(
                    initialValue: correo,
                    onChanged: (user) {
                      correo = user;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (x) => !Global.emailRegEXp.hasMatch(x ?? "")
                        ? AppLocalizations.of(context)!.invMail
                        : null,
                  )),
              ListTile(
                title: Text(AppLocalizations.of(context)!.enterPhone,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                  title: TextFormField(
                    initialValue: telefono,
                    onChanged: (user) {
                      telefono = user;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (x) => !Global.phoneRegExp.hasMatch(x ?? "")
                        ? AppLocalizations.of(context)!.invPhone
                        : null,
                  )),
              ListTile(
                  title: MaterialButton(
                      child: Text(AppLocalizations.of(context)!.signUp,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        //TODO VALIDAR USUARIO Y CREAR CUENTA
                      }
                  )
              ),
    ]
    )
    );
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


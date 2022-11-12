
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapastop/firebase_operations/authenticator.dart';
import 'package:tapastop/screens/loginScreen.dart';
import '../model/Response.dart';
import '../model/userViewModel.dart';
import '../utils/navigator.dart';
import 'package:tapastop/firebase_operations/databaseAPI.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
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
      child: ProfileScreenPage(),
    );
  }
}

class ProfileScreenPage extends StatefulWidget {
  const ProfileScreenPage({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  DocumentSnapshot? snapshot;
  String? _profilePic;
  String? _name;
  String? _email;
  String? _phone;
  

  Future<void> loadSnapshot() async {
    return await Provider.of<UserVM>(context, listen: false).loadUser(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void initState() {
    Database db = Database();
    FirebaseAuthenticator auth = FirebaseAuthenticator();
    Future<DocumentSnapshot<Map<String, dynamic>>>? user = db.getUser(auth.getCurrentUID() ?? "");
    user.then((value) {
      setState(() {
        snapshot = value;
        print(snapshot?.data());
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // snapshot = Provider.of<UserVM>(context).userResponse.data;
    // Response res = Provider.of<UserVM>(context).assetResponse;
    // if (res.status == Status.COMPLETED) {
    //   _profilePic = (res.data as Map<String, String>)["pfp"];
    // }


    return Scaffold(
      appBar: AppBar(
        title: Text(
       "${snapshot?.get('nombre')}  ${snapshot?.get('apellido')}"?? "No name"),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Container(
          child: ListView(
                children: [
                  const Divider(height: 20,),
                  Text("Correo: ${FirebaseAuth.instance.currentUser?.email}"?? "No email"),
                  const Divider(height: 20,),
                  Text("Biografía: ${snapshot?.get('presentacion')}"?? "No bio"),
                  const Divider(height: 20,),
                  Text("Fecha de nacimiento: ${snapshot?.get('edad')}"?? "No age"),
                  const Divider(height: 20,),
                  Text("Localidad: ${snapshot?.get('localidad')}"?? "No age"),
                  const Divider(height: 20,),
                  ElevatedButton(onPressed: () {FirebaseAuth.instance.signOut();   Navigator.pushAndRemoveUntil(
                      context, MyNavigator.createRoute(const LoginScreen()), (
                      Route<dynamic> route) => false);}, child: Text("Cerrar Sesión")),
    ]
      )
      )
    );
  }

}
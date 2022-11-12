
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tapastop/screens/loginScreen.dart';
import '../model/Response.dart';
import '../model/userViewModel.dart';
import '../utils/navigator.dart';

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

  Future<void> loadSnapshot() async {
    return await Provider.of<UserVM>(context, listen: false).loadUser(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    // snapshot = Provider.of<UserVM>(context).userResponse.data;
    // Response res = Provider.of<UserVM>(context).assetResponse;
    // if (res.status == Status.COMPLETED) {
    //   _profilePic = (res.data as Map<String, String>)["pfp"];
    // }
    DocumentSnapshot<Map<String, dynamic>>? user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
        user?.get("nombre") ?? "Nombre no encontrado",
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Container(
          child: Column(
                children: [
                  ElevatedButton(onPressed: () {FirebaseAuth.instance.signOut();   Navigator.pushAndRemoveUntil(
                      context, MyNavigator.createRoute(const LoginScreen()), (
                      Route<dynamic> route) => false);}, child: Text("Cerrar Sesión")),
    ]
      )
      )
    );
  }

}
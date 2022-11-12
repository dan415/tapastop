
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/Response.dart';
import '../model/userViewModel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    snapshot = Provider.of<UserVM>(context).userResponse.data;
    Response res = Provider.of<UserVM>(context).assetResponse;
    if (res.status == Status.COMPLETED) {
      _profilePic = (res.data as Map<String, String>)["pfp"];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
        "@${snapshot?.get("username") ?? "Username not found"}",
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Container()

    );
  }

}
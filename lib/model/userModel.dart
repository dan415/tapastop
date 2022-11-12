import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserSignUpModel {
  String username;
  String password;
  String email;
  String birthday;

  UserSignUpModel({this.username = "", this.password = "", this.email = "", this.birthday = ""});
}

enum DocumentFields { username, followers, following, bio, displayName, birthday, phone }

class UserOperModel {
  Future<void> documentUpdate(DocumentFields field, dynamic value) {
    CollectionReference users = FirebaseFirestore.instance.collection("users");
    return users.doc(FirebaseAuth.instance.currentUser!.uid).update({
      field.toString().split(".").last: value,
    });
  }

  Future<void> updateUsername(String username) {
    return FirebaseDatabase.instance
        .reference()
        .child("usernames/${FirebaseAuth.instance.currentUser!.uid}")
        .update(
      {
        FirebaseAuth.instance.currentUser!.uid: username,
      },
    ).then(
      (_) => FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "username": username,
      }),
    );
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return FirebaseFirestore.instance.collection("users").doc(uid).get();
  }

  Future<void> uploadAsset(String path, File asset) {
    return FirebaseStorage.instance.ref(path).putFile(asset);
  }

  Future<String> getAsset(String path) {
    return FirebaseStorage.instance.ref(path).getDownloadURL();
  }

  Future<void> resetPass() {
    return FirebaseAuth.instance
        .sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser!.email!);
  }
}

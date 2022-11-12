import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tapastop/model/userModel.dart';

import 'Response.dart';


enum AssetType { profile }

/// This provider is the one responsible for user data management:
/// Uploading and downloading data from firebase such as user info (e-mail, username, etc)
/// One example of use:
/// ...
///   var snapshot = Provider.of<UserVM>(context).userResponse;
///   displayAsString(snapshot ?? "");
/// ...
///   Provider.of<UserVM>(context, listen: false).loadUser(uid);
class UserVM extends ChangeNotifier {
  Response _docUpdateResponse = Response.initial("No request");
  Response get docUpdateResponse => _docUpdateResponse;
  Future<void> updateUserDoc(DocumentFields field, dynamic value) async {
    try {
      await UserOperModel().documentUpdate(field, value);
      _docUpdateResponse = Response.initial("No data from dUpd request");
    } on Exception catch (e) {
      _docUpdateResponse = Response.error("Doc update failed: \n$e");
    }
    notifyListeners();
  }

  Response _uNameUpdateResponse = Response.initial("No request");
  Response get uNameUpdateResponse => _uNameUpdateResponse;
  Future<void> updateUsername(String value) async {
    try {
      await UserOperModel().updateUsername(value);
      _uNameUpdateResponse = Response.initial("No data from uUpd request");
    } on Exception catch (e) {
      _uNameUpdateResponse = Response.error("User update failed: \n$e");
    }
    notifyListeners();
  }

  Response _userResponse = Response.initial("No user was requested");
  Response get userResponse => _userResponse;
  Future<void> loadUser(String uid) async {
    DocumentSnapshot? snapshot;
    try {
      snapshot = await UserOperModel().getUser(uid);
      _userResponse = Response.completed(snapshot);
    } on Exception catch (e) {
      _userResponse = Response.error("Error getting user: \n$e");
    }
    notifyListeners();
  }

  Response _setAssetResponse = Response.initial("No request");
  Response get setAssetResponse => _setAssetResponse;
  Future<void> setAsset(File asset) async {
    try {
      DocumentSnapshot data = await UserOperModel().getUser(FirebaseAuth.instance.currentUser!.uid);
        await UserOperModel().uploadAsset("profiles/${data.get("assetLocation")}/pfp.jpg", asset);
      }
    catch (e) {
      _setAssetResponse = Response.error("Failed to upload asset: \n$e");
    }
    notifyListeners();
  }

  Response _assetResponse = Response.initial("No asset request");
  Response get assetResponse => _assetResponse;
  Future<void> loadUserAssets() async {
    Map<String, String> assetUri = {};
    try {
      DocumentSnapshot data = await UserOperModel().getUser(FirebaseAuth.instance.currentUser!.uid);
      String tempUri =
          await UserOperModel().getAsset('profiles/${data.get("assetLocation")}/pfp.jpg');
      assetUri["pfp"] = tempUri;
      _assetResponse = Response.completed(assetUri);
    } on Exception catch (e) {
      _assetResponse = Response.error("Error fetching asset: \n$e");
    }
    notifyListeners();
  }

  Response _passResetResponse = Response.initial("No asset request");
  Response get passResetResponse => _passResetResponse;
  Future<void> resetPass() async {
    try {
      await UserOperModel().resetPass();
      _passResetResponse = Response.initial("No data from setAsset request");
    } on Exception catch (e) {
      _passResetResponse = Response.error("Couldn't load asset: \n$e");
    }
  }
}

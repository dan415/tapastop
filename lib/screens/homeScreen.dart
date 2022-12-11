import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tapastop/screens/GalardonScreen.dart';
import 'package:tapastop/screens/SearchScreen.dart';
import 'package:tapastop/screens/feedScreen.dart';
import 'package:tapastop/screens/helpScreen.dart';
import 'package:tapastop/screens/profileScreen.dart';
import 'package:tapastop/screens/settingScreen.dart';
import '../firebase_operations/authenticator.dart';
import '../firebase_operations/databaseAPI.dart';
import '../utils/imageutils.dart';
import '../utils/navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}


class HomeScreenState extends State<HomeScreen> {
  Database db = Database();
  FirebaseAuthenticator auth = FirebaseAuthenticator();
  DocumentSnapshot? snapshot;
  String nofoto = "res/no-image.png";
  String uid =  FirebaseAuth.instance.currentUser!.uid;
  String? foto;
  Map<String, String> galfotos = {};
  bool viewmore_profile = false;
  bool viewmore_gals = false;
  List<dynamic> gals = [];
  List<Widget> gals_widgets = [];

  @override
  void initState() {
    Future<DocumentSnapshot<Map<String, dynamic>>>? user = db.getUser(uid);
    user.then((value) {
      setState(() {
        snapshot = value;
        if(uid != "") {
          db.getAvatar(auth.getCurrentUID()!).then((value) {
            Uint8List? post_image_bytes = value;
            ImageUtils.getPhotoPath(post_image_bytes, uid).then((value) {
              setState(() {
                foto = value;
              });
            });
          })
              .onError((error, stackTrace) {
            Uint8List? postImageBytes = null;
            ImageUtils.getPhotoPath(postImageBytes, null).then((value) {
              setState(() {
                foto = value;
              });
            });
          }
          );
        }
        else{
          Uint8List? postImageBytes = null;
          ImageUtils.getPhotoPath(postImageBytes, null).then((value) {
            setState(() {
              foto = value;
            });
          });
        }
      });
    });
    db.getGalardonesUsuario(uid).then((value) {
      setState(() {
        gals = value;
        for(int i = 0; i < min(gals.length, 3); i++){
          String nombre_foto = gals[i].data()["foto"];
          db.getFotoGal(nombre_foto).then((value) {
            Uint8List? post_image_bytes = value;
            ImageUtils.getPhotoPath(post_image_bytes, nombre_foto).then((value) {
              setState(() {

                galfotos[gals[i].id] = value;
                print(galfotos);
              });
            });
          })
              .onError((error, stackTrace) {
                print(error);
            Uint8List? postImageBytes = null;
            ImageUtils.getPhotoPath(postImageBytes, null).then((value) {
              setState(() {
                galfotos[gals[i].id] = value;
              });
            });
          }
          );
        }
      });
    });
    super.initState();
  }

  Widget galardonWidget(dynamic galardon){
    double _screenWidth = MediaQuery.of(context).size.width;
    print(galfotos[galardon.id])  ;
    return Row(

      children: [
        const Padding(padding: EdgeInsets.only(left: 5)),
        ClipRRect(
            borderRadius: BorderRadius.circular(_screenWidth / 12),
            child: Container(
              color: Colors.white,
              child: (nofoto == galfotos[galardon.id] || galfotos[galardon.id] == null) ?
              Image.asset(
                nofoto,
                fit: BoxFit.cover,
                height: _screenWidth * 0.08,
                width: _screenWidth * 0.08,
              ) :
              Image.file(File(galfotos[galardon.id]!),
                fit: BoxFit.cover,
                height: _screenWidth * 0.08,
                width: _screenWidth * 0.08,
              ),
            )
        ),
        Padding(padding: EdgeInsets.only(left: 5)),
        Text("${galardon.id.replaceAll("_", " ")}"?? "No name", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.only(left: 10)),
        Column(
          children:[
            const Text("Nivel", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("${galardon.data()['nivel']}"?? "unknown", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]
        )
      ]
    );
  }

  Widget galardonesBox() {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: Column(children: [
        Padding(padding: EdgeInsets.only(top: 20)),
        Text("Resumen Galardones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: gals_widgets,
        )
      ],),
    );
  }

  Widget profilebox() {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
        color: Theme.of(context).primaryColorLight,
        child: Column( children: [
          const Padding(padding: EdgeInsets.only(top: 20)),
          ClipRRect(
              borderRadius: BorderRadius.circular(_screenWidth / 8),
              child: Container(
                color: Colors.white,
                child: (nofoto == foto || foto == null) ?
                Image.asset(
                  nofoto,
                  fit: BoxFit.cover,
                  height: _screenWidth * 0.15,
                  width: _screenWidth * 0.15,
                ) :
                Image.file(File(foto!),
                  fit: BoxFit.cover,
                  height: _screenWidth * 0.15,
                  width: _screenWidth * 0.15,
                ),
              )
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          Text("${snapshot?.get('nombre')}"?? "No name", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(" ${snapshot?.get('apellido')}" ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ])
    );
  }

  Widget appbar(){
    return AppBar();
  }


  @override
  Widget build(BuildContext context) {
    gals_widgets = [];
    for (int i = 0; i < gals.length; i++) {
      gals_widgets.add(galardonWidget(gals[i]));
    }
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0), // here the desired height
            child: AppBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              centerTitle: true,
              title: Text("Menu"),
            )
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
      children: [
                        Container(
                          color: Theme.of(context).primaryColorLight,
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MyNavigator.createRoute(const SearchScreen(), isAnimated: true)),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                                child: Column( children: const [Icon(Icons.search, size: 100,), Text("Buscar")])
                            ),
                          ),
                        ),

                    Container(
                      color: Theme.of(context).primaryColorLight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MyNavigator.createRoute(const ProfileScreen(), isAnimated: true)),
                        child: Container(
                            width: 50,
                            height: 50,
                            child: Column( children: const [Icon(Icons.man, size: 100,), Text("Perfil")])

                        ),
                      ),
                    ),

                    Container(
                      color: Theme.of(context).primaryColorLight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MyNavigator.createRoute(const HelpScreen(), isAnimated: true)),
                        child: Container(
                            width: 50,
                            height: 50,
                            child: Column( children: const [Icon(Icons.help, size: 100,), Text("Ayuda")])

                        ),
                      ),
                    ),

                    Container(
                      color: Theme.of(context).primaryColorLight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MyNavigator.createRoute(const GalardonScreen(), isAnimated: true)),
                        child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Column( children: const [Icon(Icons.check, size: 100,), Text("Galardones")])

                        ),
                      ),
                    ),

                  Container(
                    color: Theme.of(context).primaryColorLight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MyNavigator.createRoute(const feedScreen(), isAnimated: true)),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Column( children: const [Icon(Icons.food_bank, size: 100,), Text("Degustaciones")])

                      ),
                    ),
                  ),
        Container(
          color: Theme.of(context).primaryColorLight,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MyNavigator.createRoute( AccountPage(), isAnimated: true)),
            child: SizedBox(
                width: 50,
                height: 50,
                child: Column( children: const [Icon(Icons.settings, size: 100,), Text("Ajustes")])

            ),
          ),
        ),
        profilebox(),
        galardonesBox(),
                ],
      )
    );
  }
}
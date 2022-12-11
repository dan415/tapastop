import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../firebase_operations/authenticator.dart';
import '../firebase_operations/databaseAPI.dart';
import '../utils/globals.dart';
import '../utils/imageutils.dart';
import '../utils/navigator.dart';

class GalardonScreen extends StatefulWidget {
  const GalardonScreen({super.key});

  @override
  GalardonScreenState createState() => GalardonScreenState();
}


class GalardonScreenState extends State<GalardonScreen> {
  Database db = Database();
  FirebaseAuthenticator auth = FirebaseAuthenticator();
  String nofoto = "res/no-image.png";
  String uid =  FirebaseAuth.instance.currentUser!.uid;
  Map<String, String> galfotos = {};
  List<dynamic> gals = [];
  List<Widget> gals_widgets = [];
  List<Map<String, String>>? galardones;

  @override
  void initState() {
    db.getGalardonesUsuario(uid).then((value) {
      setState(() {
        gals = value;
        for(int i = 0; i < gals.length; i++){
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
    print(galfotos[galardon.id]) ;
    return ListTile(
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(_screenWidth / 8),
          child: Container(
            color: Colors.white,
            child: (nofoto == galfotos[galardon.id] || galfotos[galardon.id] == null) ?
            Image.asset(
              nofoto,
              fit: BoxFit.cover,
              height: _screenWidth * 0.15,
              width: _screenWidth * 0.15,
            ) :
            Image.file(File(galfotos[galardon.id]!),
              fit: BoxFit.cover,
              height: _screenWidth * 0.15,
              width: _screenWidth * 0.15,
            ),
          )
      ),
      title:   Text("${galardon.id.replaceAll("_", " ")}"?? "No name", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      subtitle: Text("${galardon.data()["descripcion"]}"?? "No description", style: const TextStyle(fontSize: 14)),
      trailing: Column(
          children:[
            const Text("Nivel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("${galardon.data()['nivel']}"?? "unknown", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]
      ) ,
    );
  }


  @override
  Widget build(BuildContext context) {
    gals_widgets = [const Divider()];
    for (int i = 0; i < gals.length; i++) {
      gals_widgets.add(galardonWidget(gals[i]));
      gals_widgets.add(const Divider());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Galardones"),
      ),
      body: ListView(
        children: gals_widgets,
      ),
    );
  }




}
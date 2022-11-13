
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tapastop/firebase_operations/authenticator.dart';
import 'package:tapastop/firebase_operations/databaseAPI.dart';
import 'package:tapastop/utils/imageutils.dart';

import '../utils/globals.dart';
import '../utils/navigator.dart';
import 'feedScreen.dart';

class createDegustacion extends StatefulWidget {
  const createDegustacion({super.key});

  @override
  createDegustacionState createState() => createDegustacionState();
}

class createDegustacionState extends State<createDegustacion> {
  String nombre = "";
  String descripcion = "";
  String restaurante = "";
  String tipos = "";
  File? foto;
  Database db = Database();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColorDark));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Preguntas Frecuentes'),
          backgroundColor: Theme.of(context).primaryColorDark,
        ),
        body: ListView(
          children: [
            const ListTile(
                title: Text("Nombre de la degustación"),
                ),
                  ListTile(
                  title: TextFormField(
                  initialValue: "",
                    onChanged: (x) {
                      nombre = x;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (x) => x!.isEmpty ? "El nombre no puede estar vacío" : null,
                  )
              ),
            const ListTile(
              title: Text("Descripción de la degustación"),
            ),
            ListTile(
                title: TextFormField(
                  initialValue: "",
                  onChanged: (x) {
                    descripcion = x;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (x) => x!.isEmpty ? "La descripción no puede estar vacío" : null,
                )
            ),
            const ListTile(
              title: Text("Restaurante"),
            ),
            ListTile(
                title: TextFormField(
                  initialValue: "",
                  onChanged: (x) {
                    restaurante = x;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (x) => x!.isEmpty ? "El restaurante no puede estar vacío" : null,
                )
            ),
            const ListTile(
              title: Text("Tipos de comida"),
            ),
            ListTile(
                title: TextFormField(
                  initialValue: "",
                  decoration: const InputDecoration(
                  hintText: 'Separados por comas',
                  ),
                  onChanged: (x) {
                    tipos = x;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (x) => x!.isEmpty ? "Los tipos no pueden estar vacíos" : null,
                )
            ),
            ElevatedButton(onPressed: () {
              setState(() async {
                 ImageUtils.choosImage(ImageType.post, context).then((value) {
                   foto = value;
                   print(foto);
                 });

              });
            },
                child: const Text("Cargar foto")),
            ElevatedButton(onPressed: () {
              db.addDegustacion(nombre, FirebaseAuthenticator().getCurrentUID()!, restaurante, descripcion, tipos.split(","));
              print(foto);
              if (foto != null) {
                db.addFotoDeg(foto!, nombre);
              }
              Navigator.push(context, MyNavigator.createRoute( feedScreen(), isAnimated: true));
            },
                 child: const Text("Crear degustación"))
              ]));
  }

}
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Database {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  addUser(String uid, String nombre, String? apellido, String? localidad,
      String edad, String? presentacion) {
    db.collection('users').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'apellido': apellido ?? '',
      'localidad': localidad ?? '',
      'edad': edad,
      'presentacion': presentacion ?? '',
    });
  }

  addPicture(File photo, String uid) {
    storage.ref().child('users').child(uid).child('avatar').putFile(photo);
  }

  Future<Uint8List?> getPicture(String uid) async {
    return storage.ref().child('users').child(uid).child('avatar').getData();
  }

  addDegustacion(String uid, String restaurante, String degustacion,
      String comentario) async {
    DocumentReference degustacionRef = db
        .collection('users')
        .doc(uid)
        .collection('degustaciones')
        .doc(degustacion);

    degustacionRef.set({
      'restaurante': restaurante,
      'comentarios.$uid': comentario,
    });

    db.collection('users').doc(uid).collection('degustaciones').add({
      'degustacion': degustacion,
    });

    addRestaurante(restaurante);

    int i = 0;
    List<String>? degustaciones = await db
        .collection('restaurantes')
        .doc(restaurante)
        .get()
        .then((value) => value.data()?.keys.toList());
    if (degustaciones != null) {
      i = degustaciones.length;
    }

    db.collection('restaurantes').doc(restaurante).update({
      'degustacion$i': FieldValue.arrayUnion([degustacion])
    });
  }

  Future<List<String>> getDegustaciones(String uid) async {
    List snapshots = await db
        .collection('users')
        .doc(uid)
        .collection('degustaciones')
        .snapshots()
        .toList();
    List<String> degustaciones = [];
    snapshots.forEach((element) {
      element.docs.forEach((element) {
        degustaciones.add(element.data()['degustacion']);
      });
    });
    return degustaciones;
  }

  addRestaurante(String restaurante) {
    db
        .collection('restaurantes')
        .doc(restaurante)
        .set({'restaurante': restaurante});
  }
}

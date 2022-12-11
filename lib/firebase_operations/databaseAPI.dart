import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum tipoGalardon { degustacion, comentario }

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
      'comentarios': [],
    });
  }

  ///DocumentSnapshot<Map<String, dynamic>> user = await getUser(uid);
  ///String uid = user.data()['uid'];
  ///String nombre = user.data()['nombre'];
  ///String? apellido = user.data()['apellido'];
  ///String? localidad = user.data()['localidad'];
  ///String edad = user.data()['edad'];
  ///String? presentacion = user.data()['presentacion'];
  ///List<String> comentarios = user.data()['comentarios'] // Estos son los comentarios que ha hecho
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return await db.collection('users').doc(uid).get();
  }

  changeUserField(String uid, String field, dynamic value) {
    db.collection('users').doc(uid).update({field: value});
  }

  addAvatar(File photo, String uid) {
    storage.ref().child('users').child(uid).putFile(photo);
  }

  Future<Uint8List?> getAvatar(String uid) async {
    return storage.ref().child('users').child(uid).getData();
  }

  addFotoDeg(File photo, String degustacion) {
    storage.ref().child('degustaciones').child(degustacion).putFile(photo);
  }

  Future<Uint8List?> getFotoDeg(String degustacion) async {
    return storage.ref().child('degustaciones').child(degustacion).getData();
  }

  Future<Uint8List?> getFotoGal(String galardon) async {
    return storage.ref().child('galardones').child(galardon).getData();
  }

  addDegustacion(String degustacion, String uid, String restaurante,
      String descripcion, List<String> tipo) async {
    await addRestaurante(restaurante);
    List<String> degustaciones = [];
    db
        .collection('restaurantes')
        .doc(restaurante)
        .get()
        .then((value) => (value.data()!['degustaciones'] as List<dynamic>).forEach((element) {
              degustaciones.add(element.toString());
            }));
    if (degustaciones.contains(degustacion)) {
      return;
    }

    db.collection('degustaciones').doc(degustacion).set({
      'user': uid,
      'descripcion': descripcion,
      'tipo': tipo,
      'restaurante': restaurante,
      'fecha': DateTime.now(),
    });

    degustaciones.add(degustacion);
    db.collection('restaurantes').doc(restaurante).update({
      'degustaciones': degustaciones,
    });
  }

  // Si no se especifica valoracion mete null en el último
  addComentario(
      String uid, String degustacion, String comentario, int? valoracion, List<String> tipos) async {
    DocumentReference deg = db.collection('degustaciones').doc(degustacion);
    String name = await db.collection('users').doc(uid).get().then((value) {
      return value.data()!['nombre'];
    });
    deg.collection('comentarios').doc(uid).set({
      'uid': name,
      'comentario': comentario,
      'valoracion': valoracion,
    });

    List<String> comentarios = [];
    await db
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      for (var i in value.data()!['comentarios']) {
        comentarios.add(i.toString());
      }
    });
    comentarios.add(degustacion);
    db.collection('users').doc(uid).update({
      'comentarios': comentarios,
    });
    for (var tipo in  tipos){
      print("tipo: $tipo");
      checkGalardonesUsuario(uid, tipo, tipoGalardon.comentario);
    }
  }

  // int valoracionMedia = getValoracionMedia(degustacion);
  Future<int> getValoracionMedia(String degustacion) async {
    int valoracion = 0;
    int numComentarios = 0;
    await db
        .collection('degustaciones')
        .doc(degustacion)
        .collection('comentarios')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data()['valoracion'] != null) {
          valoracion += element.data()['valoracion']! as int;
          numComentarios++;
        }
      });
    });
    return valoracion > 0 ? valoracion ~/ numComentarios : 0;
  }

  ///DocumentSnapshot<Map<String, dynamic>> d = await getInfoDegustacion('degustacion');
  ///String descripcion = d['descripcion'];
  ///List<String> tipo = d['tipo'];
  ///String restaurante = d['restaurante'];
  ///DateTime fecha = d['fecha'];
  ///String user = d['user'];
  Future<DocumentSnapshot<Map<String, dynamic>>> getInfoDegustacion(
      String degustacion) {
    return db.collection('degustaciones').doc(degustacion).get();
  }

  ///QuerySnapshot<Map<String, dynamic>> comentarios = await getComentarios('degustacion');
  ///comentarios.docs.forEach((element) {
  ///		String uid = element.id;
  ///		String comentario = element['comentario'];
  ///		int valoracion = element['valoracion'];
  ///});
  Future<QuerySnapshot<Map<String, dynamic>>> getComentarios(
      String degustacion) {
    return db
        .collection('degustaciones')
        .doc(degustacion)
        .collection('comentarios')
        .get();
  }

  ///List<String> degustaciones = await getDegustacionesUsuario('uid');
  ///Cada elemento de degustaciones es el nombre (ref) de una degustacion
  Future<List<dynamic>> getDegustacionesUsuario(String uid) async {
    List<dynamic> degustaciones = [];
    await db
        .collection('degustaciones')
        .get()
        .then((value) {
      for(var i in value.docs){
        if(i.data()['user'] == uid){
          degustaciones.add(i);
        }
      }
    });
    return degustaciones;
  }

  Future<List<dynamic>> getGalardonesUsuario(String uid) async {
    List<dynamic> galardones = [];
    await db
        .collection('users')
        .doc(uid)
        .collection("galardones")
        .orderBy('fecha', descending: true)
        .get()
        .then((value) {
      for(var i in value.docs){
        galardones.add(i);
      }
    });
    return galardones;
  }

Future<List<dynamic>> getComentariosUsuario(String uid) async {
    List<dynamic> comentarios = [];
    await db
        .collection('users')
        .doc(uid)
        .get()
        .then((value) {
      for(var i in value.data()!['comentarios']){
        comentarios.add(i);
      }
    });
    return comentarios;
  }

  carrycount(dynamic galardones, int count, String uid, String cat, tipoGalardon tipo ){
    galardones.forEach((galardon) {
      print(galardon.data());
      if ( ((galardon.data()['tipo']=="comentar" && tipo==tipoGalardon.comentario) || (galardon.data()['tipo']=="añadir" && tipo==tipoGalardon.degustacion) )&& galardon.data()['tipo_comida']==cat){
        for(var i = 10; i>0; i--){
          if (count>=galardon.data()['n$i']){
            addGalardon(uid, galardon.id, galardon.data()["descripcion"], i.toString(), galardon.data()["foto"]);
            break;
          }
        }
      }
    });
  }

  checkGalardonesUsuario(String uid, String cat, tipoGalardon tipo) async {
    int count = 0;
    await getGalardones().then((galardones) => {
      if (tipo==tipoGalardon.degustacion){
        getDegustacionesUsuario(uid).then((degs) async {
          for(var element in degs){
            var deg = await getInfoDegustacion(element.id);
            if (deg.data()!['tipo'].contains(cat)){
              count++;
            }
          }
          carrycount(galardones, count, uid, cat, tipo);
        })
      }
      else {
        getComentariosUsuario(uid).then((coms) async {
          for(var element in coms){
            var deg = await getInfoDegustacion(element);
            if (deg.data()!['tipo'].contains(cat)){
              count++;
            }
          }
          carrycount(galardones, count, uid, cat, tipo);
        })
      },
    });
  }

  addGalardon(
      String uid, String nombre, String descripcion, String nivel, String foto) async {
    DocumentReference user = db.collection('users').doc(uid);
    user.collection('galardones').doc(nombre).set({
      'nivel': nivel,
      "descripcion": descripcion,
      'fecha': DateTime.now(),
      'foto': foto,
    });
  }

  ///List<String> degustaciones = await getDegustacionesRestaurante('restaurante');
  ///Cada elemento de degustaciones es el nombre (ref) de una degustacion
  Future<List<String>> getDegustacionesRestaurante(String restaurante) async {
    print(restaurante);
    List<String> degustaciones = [];
    await db
        .collection('restaurantes')
        .doc(restaurante)
        .get()
        .then((value) {
      for(var i in value.data()!['degustaciones']){
        degustaciones.add(i.toString());

      }
    });
    print(degustaciones);
    return degustaciones;
  }

  Future<List<dynamic>> getDegustacionesTipo(String tipo) async {
    List<dynamic> degustaciones = [];
    await db
        .collection('degustaciones')
        .get().then((value) {
          value.docs.forEach((element) {
            if(element.data()['tipo'].contains(tipo)){
              degustaciones.add(element);
            }
          });
        });
    return degustaciones;
  }

  Future<List<dynamic>> getGalardones() async {
    List<dynamic> galardones = [];
    await db
        .collection('galardones')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        galardones.add(element);
      });
    });
    return galardones;
  }





  ///List<String> degustaciones = await getDegustaciones();
  ///Cada elemento de degustaciones es el nombre (ref) de una degustacion ordenados por fecha
  Future<List<String>> getDegustaciones() async {
    List<String> degustaciones = [];
    await db
        .collection('degustaciones')
        .orderBy('fecha', descending: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        degustaciones.add(element.id);
      });
    });
    return degustaciones;
  }

  addRestaurante(String restaurante) async {
    if (await db.collection('restaurantes').doc(restaurante).get().then(
            (value) => value.exists) ==
        false) {
      db.collection('restaurantes').doc(restaurante).set({
        'degustaciones': [],
      });
    }
  }
}

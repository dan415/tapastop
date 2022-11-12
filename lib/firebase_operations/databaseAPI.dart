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


  addAvatar(File photo, String uid) {
    storage.ref().child('users').child(uid).child('avatar').putFile(photo);
  }

  Future<Uint8List?> getAvatar(String uid) async {
    return storage.ref().child('users').child(uid).child('avatar').getData();
  }

	addFotoDeg(File photo, String degustacion) {
    storage.ref().child('degustaciones').child(degustacion).child('pic').putFile(photo);
  }
  
	Future<Uint8List?> getFotoDeg(String degustacion) async {
		return storage.ref().child('degustaciones').child(degustacion).child('pic').getData();
	}

	addDegustacion(String degustacion, String restaurante, String descripcion, List<String> tipo) {
		List<String> degustaciones = db.collection('restaurantes').doc(restaurante).get().then((value) => value.data()!['degustaciones']) as List<String>;
		if (degustaciones.contains(degustacion)) {
			return;
		}

		db.collection('degustaciones').doc(degustacion).set({ 
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
	addComentario(String uid, String degustacion, String comentario, int? valoracion) {
		DocumentReference deg = db.collection('degustaciones').doc(degustacion);
		deg.collection('comentarios').doc(uid).set({
			'comentario': comentario,
			'valoracion': valoracion,
		});
		
		List<String> comentarios = db.collection('users').doc(uid).get().then((value) => value.data()!['comentarios']) as List<String>;
		comentarios.add(degustacion);
		db.collection('users').doc(uid).update({
			'comentarios': degustacion,
		});
	}

	// int valoracionMedia = getValoracionMedia(degustacion);
	Future<int> getValoracionMedia(String degustacion) async {
		int valoracion = 0;
		int numComentarios = 0;
		await db.collection('degustaciones').doc(degustacion).collection('comentarios').get().then((value) {
			value.docs.forEach((element) {
				if (element.data()['valoracion'] != null) {
					valoracion += element.data()['valoracion']! as int;
					numComentarios++;
				}
			});
		});
		return valoracion ~/ numComentarios;
	}

	///DocumentSnapshot<Map<String, dynamic>> d = await getInfoDegustacion('degustacion');
	///String descripcion = d['descripcion'];
	///List<String> tipo = d['tipo'];
	///String restaurante = d['restaurante'];
	///DateTime fecha = d['fecha'];
	Future<DocumentSnapshot<Map<String, dynamic>>> getInfoDegustacion(String degustacion) {
		return db.collection('degustaciones').doc(degustacion).get();
	}

	///QuerySnapshot<Map<String, dynamic>> comentarios = await getComentarios('degustacion');
	///comentarios.docs.forEach((element) {
	///		String uid = element.id;
	///		String comentario = element['comentario'];
	///		int valoracion = element['valoracion'];
	///});
	Future<QuerySnapshot<Map<String, dynamic>>> getComentarios(String degustacion) {
		return db.collection('degustaciones').doc(degustacion).collection('comentarios').get();
	}

	///List<String> degustaciones = await getDegustacionesUsuario('uid');
	///Cada elemento de degustaciones es el nombre (ref) de una degustacion
  Future<List<String>> getDegustacionesUsuario(String uid) async {
		return db.collection('users').doc(uid).get().then((value) => value.data()!['degustaciones']) as List<String>;
	}

	///List<String> degustaciones = await getDegustacionesRestaurante('restaurante');
	///Cada elemento de degustaciones es el nombre (ref) de una degustacion
	Future<List<String>> getDegustacionesRestaurante(String restaurante) async {
		return db.collection('restaurantes').doc(restaurante).get().then((value) => value.data()!['degustaciones']) as List<String>;
	}

	///List<String> degustaciones = await getDegustaciones();
	///Cada elemento de degustaciones es el nombre (ref) de una degustacion ordenados por fecha
	Future<List<String>> getDegustaciones() async {
		List<String> degustaciones = [];
		await db.collection('degustaciones').orderBy('fecha', descending: true).get().then((value) {
			value.docs.forEach((element) {
				degustaciones.add(element.id);
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

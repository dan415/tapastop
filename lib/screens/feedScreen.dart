
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tapastop/screens/createDegustacion.dart';
import 'package:tapastop/utils/globals.dart';
import 'package:tapastop/utils/imageutils.dart';

import '../firebase_operations/authenticator.dart';
import '../firebase_operations/databaseAPI.dart';
import '../utils/navigator.dart';
import '../utils/starRating.dart';

class feedScreen extends StatefulWidget {
  const feedScreen({super.key});

  @override
  feedScreenState createState() => feedScreenState();
}


class feedScreenState extends State<feedScreen> {
  List<Map<String, dynamic>> degustaciones_list = [];
  List<String> degustaciones_names = [];
  late Database db;
  late FirebaseAuthenticator auth;
  int rating = 0;
  String nofoto = "res/no-image.png";
  Map<String, dynamic> comentarios = {};
  Map<String, dynamic> valoraciones = {};
  Map<String, dynamic> fotos = {};

  @override
  @override
  void initState() {
    db = Database();
    auth = FirebaseAuthenticator();
    Future<List<String>>? degustaciones = db.getDegustaciones();
    degustaciones.then((value) {
      setState(() {
        degustaciones_names = value;
        print(degustaciones_names);
        for (var degus  in degustaciones_names) {
          db.getInfoDegustacion(degus).then((value) {
            setState(() {
              print(value.data());
              var ele = <String, dynamic>{};
              ele.addAll(value.data()!);
              ele["nombre"] = degus;
              degustaciones_list.add(ele);
            });
          });
          db.getComentarios(degus).then((value) {
            setState(() {
              comentarios[degus] = value;
            });
          });
          db.getValoracionMedia(degus).then((value) {
            setState(() {
              valoraciones[degus] = value * 1.0;
            });
          });
          db.getFotoDeg(degus).then((value) {
            Uint8List? post_image_bytes = value;
            ImageUtils.getPhotoPath(post_image_bytes, degus).then((value) {
              setState(() {
                fotos[degus] = value;
                print(value);
              });
            });
          })
          .onError((error, stackTrace) {
            Uint8List? postImageBytes = null;
            ImageUtils.getPhotoPath(postImageBytes, degus).then((value) {
              setState(() {
                fotos[degus] = value;
                print(value);
              });
            });
          }
          );
        }
      });
    });
    super.initState();
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = '${diff.inDays} days ago';
      } else {
        time = '${diff.inDays} days ago';
      }
    }

    return time;
  }
  
  Widget post_image(degustacion)  {

    return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: (nofoto != fotos[degustacion['nombre']]) ?  Image.file(File(fotos[degustacion['nombre']])) : Image.asset(fotos[degustacion['nombre']]));
  }

  
  Widget degustacion(degustacion){
    String comentario = "";
    int? valoracion;

    return  Column(
      children: [
       Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               fotos[degustacion['nombre']] == null ? const LoadingIndicator(indicatorType: Indicator.semiCircleSpin) : post_image(degustacion),
               Text(degustacion['nombre'], style: const TextStyle(fontSize: 15, color: Colors.black, ),),
               Text(degustacion['tipo'][0], style: const TextStyle(fontSize: 15, color: Colors.black)),
               Text(degustacion['descripcion'], style: const TextStyle(fontSize: 15, color: Colors.black)),
               Text(degustacion['restaurante'], style: const TextStyle(fontSize: 15, color: Colors.black)),
               Text(readTimestamp(degustacion['fecha'].seconds*1000).toString(), style: const TextStyle(fontSize: 15, color: Colors.black)),
                StarRating(
                    rating: valoraciones[degustacion['nombre']] ?? 0.0,
                    onRatingChanged: (rating) => {}, color: Theme.of(context).primaryColor,)
              ]
        ),
        const Divider(height: 10.0),
        TextFormField(
           keyboardType: TextInputType.number,
            onChanged: (cm) {
              valoracion = int.parse(cm);
            },
            decoration: const InputDecoration(
              hintText: 'Introduce una valoración entre 0 y 5',)
        ),
        TextFormField(
            onChanged: (cm) {
              comentario = cm;
            },
          decoration: InputDecoration(
            suffix: IconButton(
                onPressed: () {
                  db.addComentario(auth.getCurrentUID()!, degustacion['nombre'], comentario, valoracion);
                }
                , icon: Icon(Icons.send)),
            hintText: 'Escribe un comentario',)
        ),
        Expanded(
          child: ListView.builder(
            itemCount: comentarios[degustacion['nombre']]?.size ?? 0,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(comentarios[degustacion['nombre']].docs[index].data()['comentario']),
                subtitle: Text("Usuario"),
              );
            },
          ),
        )
      ],
    );
  }

  List<Widget> degustaciones_widgets(){
    List<Widget> degustaciones = [];
    for (var degustacion in degustaciones_list) {
      degustaciones.add(this.degustacion(degustacion));
    }
    return degustaciones;
  }

  PreferredSizeWidget? bar(){
    return AppBar(
      title: const Text("Degustaciones"),
      elevation: 0,
      centerTitle: true,
        automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.create),
          onPressed: () {
            Navigator.push(context, MyNavigator.createRoute( createDegustacion(), isAnimated: true));
          },
        )
      ],
    );
  }

  Widget build(BuildContext context) {
    List<Widget> degustaciones =  [];

    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      appBar: bar(),
      body: PageView(
        scrollDirection: Axis.vertical,
        controller: controller,
        children: degustaciones_list.isEmpty ? [const Center(child: CircularProgressIndicator())] : degustaciones_widgets(),
      ),
    );
  }

}
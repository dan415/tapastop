
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tapastop/screens/createDegustacion.dart';
import 'package:tapastop/utils/globals.dart';

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
  Map<String, dynamic> comentarios = {};
  Map<String, dynamic> valoraciones = {};
  late String username;

  @override
  @override
  void initState() {
    db = Database();
    auth = FirebaseAuthenticator();
    Future<List<String>>? degustaciones = db.getDegustaciones();

    db.getUser(auth.getCurrentUID().toString()).then((value) {
      username = value.data()?['nombre'];
    });
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

  Widget degustacion(degustacion){
    String comentario = "";
    int? valoracion;

    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: bar(),
        body: Column(
      children: [
       Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Paddings.horizontalPadding(size: 300),
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
                subtitle: Text(username),
              );
            },
          ),
        )
      ],
    )
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
          icon: const Icon(Icons.add),
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

    return PageView(
      scrollDirection: Axis.vertical,
      controller: controller,
      children: degustaciones_list.isEmpty ? [
         Scaffold(appBar: bar(), body:LoadingIndicator(indicatorType: Indicator.ballPulse))] : degustaciones_widgets(),
    );
  }

}
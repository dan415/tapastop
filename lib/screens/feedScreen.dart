
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

class feedScreen extends StatefulWidget {
  const feedScreen({super.key});

  @override
  feedScreenState createState() => feedScreenState();
}


class feedScreenState extends State<feedScreen> {
  List<Map<String, dynamic>> degustaciones_list = [];
  List<String> degustaciones_names = [];

  @override
  void initState() {
    Database db = Database();
    FirebaseAuthenticator auth = FirebaseAuthenticator();
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
              print(ele);
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
              ]
        ),
        const Divider(height: 10,),
        TextFormField(
          decoration: InputDecoration(
            suffix: IconButton(
                onPressed: () {

                }
                , icon: Icon(Icons.send)),
            hintText: 'Escribe un comentario',)
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Comentario'),
                subtitle: Text('Usuario'),
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

    return PageView(
      scrollDirection: Axis.vertical,
      controller: controller,
      children: degustaciones_list.isEmpty ? [
         Scaffold(appBar: bar(), body:LoadingIndicator(indicatorType: Indicator.ballPulse))] : degustaciones_widgets(),
    );
  }

}
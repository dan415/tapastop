import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../firebase_operations/authenticator.dart';
import '../firebase_operations/databaseAPI.dart';
import '../utils/imageutils.dart';
import '../utils/starRating.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  Database db = Database();
  int? filtro = 0;
  String _searchText = "";
  List<String> _searchList = [];
  String nofoto = "res/no-image.png";
  FirebaseAuthenticator auth = FirebaseAuthenticator();
  List<Map<String, dynamic>> degustaciones_list = [];
  Map<String, dynamic> comentarios = {};
  Map<String, dynamic> valoraciones = {};
  Map<String, dynamic> fotos = {};

  List<Widget> degustaciones_widgets(){
    List<Widget> degustaciones = [];
    for (var degustacion in degustaciones_list) {
      degustaciones.add(this.degustacion(degustacion));
    }
    return degustaciones;
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
                subtitle: Text(comentarios[degustacion['nombre']].docs[index].data()['uid']),
              );
            },
          ),
        )
      ],
    );
  }

  set_widgets(){
    for(var result in _searchList){
      db.getInfoDegustacion(result).then((value) {
        setState(() {
          print(value.data());
          var ele = <String, dynamic>{};
          ele.addAll(value.data()!);
          ele["nombre"] = result;
          degustaciones_list.add(ele);
        });
      });
      db.getComentarios(result).then((value) {
        setState(() {
          comentarios[result] = value;
        });
      });
      db.getValoracionMedia(result).then((value) {
        setState(() {
          valoraciones[result] = value * 1.0;
        });
      });
      db.getFotoDeg(result).then((value) {
        Uint8List? postImageBytes = value;
        ImageUtils.getPhotoPath(postImageBytes, result).then((value) {
          setState(() {
            fotos[result] = value;
            print(value);
          });
        });
      })
          .onError((error, stackTrace) {
        Uint8List? postImageBytes = null;
        ImageUtils.getPhotoPath(postImageBytes, result).then((value) {
          setState(() {
            fotos[result] = value;
            print(value);
          });
        });
      });
  }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                    ),
                    onChanged: (text) {
                      setState(() {
                        _searchText = text;
                        _searchList = [];
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    degustaciones_list = [];
                    _searchList = [];
                    comentarios = {};
                    valoraciones = {};
                    fotos = {};
                    List<String> degs = [];
                    if(filtro == 0) {
                      degs = await db.getDegustaciones();
                    }
                    else if (filtro == 1){
                      degs = await db.getDegustacionesRestaurante(_searchText);
                    }
                    for (var d in degs) {
                      _searchList.add(d);
                    }
                    setState(() {
                      set_widgets();
                    });
                    FocusScope.of(context).unfocus();
                    },
                ),
              ],
            ),
            Row(
              children: [
                Text("Filtrar por:"),
                DropdownButton(items:
                    const [
                      DropdownMenuItem(child: Text("Nombre"), value: 0),
                      DropdownMenuItem(child: Text("Restaurante"), value: 1),
                    ]
                    , onChanged: (value) {
                      setState(() {
                        filtro = value;
                      });
                    }, value: filtro),
              ],
            ),
            Expanded(
              child: PageView(
                children: _searchList.isEmpty ? [Container()]: degustaciones_widgets(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

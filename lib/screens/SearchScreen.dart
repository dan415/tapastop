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

  @override
  void initState() {
    super.initState();
    search().then((value) {
      degustaciones_list.sort((a, b) =>  valoraciones[b['nombre']].compareTo(valoraciones[a['nombre']]));
      degustaciones_list = degustaciones_list.reversed.toList();
      setState(() {});
    });
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

  search() async {
    degustaciones_list = [];
    _searchList = [];
    comentarios = {};
    valoraciones = {};
    fotos = {};
    List<String> degs = [];
    if(_searchText.isEmpty){
      degs = await db.getDegustaciones();
    }
    else if(filtro == 0) {
      degs = await db.getDegustaciones();
      degs.retainWhere((element) => element == _searchText);
    }
    else if (filtro == 1){
      degs = await db.getDegustacionesRestaurante(_searchText);
    }
    else if (filtro == 2){
      var deg_future = await db.getDegustacionesTipo(_searchText);
      deg_future.forEach((element) {
        degs.add(element.id);});
    }
    for (var d in degs) {
      _searchList.add(d);
    }
    setState(() {set_widgets();});
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
                    List<String> tipos_str = [];
                    degustacion['tipo'].forEach((element) {
                      tipos_str.add(element.toString());
                    });
                    db.addComentario(auth.getCurrentUID()!, degustacion['nombre'], comentario, valoracion, tipos_str);
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

  set_widgets() async {
    print("searchlist: $_searchList");
    for(var result in _searchList){
      var info = await db.getInfoDegustacion(result);
      var ele = <String, dynamic>{};
      ele.addAll(info.data()!);
      ele["nombre"] = result;
      degustaciones_list.add(ele);
      var val = await db.getValoracionMedia(result);
      valoraciones[result] = val * 1.0;
      print(info.data());
      db.getComentarios(result).then((value) {
        setState(() {
          comentarios[result] = value;
        });
      });
      db.getFotoDeg(result).then((value) {
        Uint8List? postImageBytes = value;
        ImageUtils.getPhotoPath(postImageBytes, result).then((value) {
          setState(() {
            fotos[result] = value;
          });
        });
      })
          .onError((error, stackTrace) {
        Uint8List? postImageBytes = null;
        ImageUtils.getPhotoPath(postImageBytes, result).then((value) {
          setState(() {
            fotos[result] = value;
          });
        });
      });
  }
    print(degustaciones_list);
    degustaciones_list.sort((a, b) =>  valoraciones[b['nombre']].compareTo(valoraciones[a['nombre']]));
    setState(() {

    });
      }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
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
                  onPressed: () async{
                    search();
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
                      DropdownMenuItem(child: Text("Tipo"), value: 2),
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
                controller: controller,
                scrollDirection: Axis.vertical,
                children: degustaciones_widgets(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class feedScreen extends StatefulWidget {
  const feedScreen({super.key});

  @override
  feedScreenState createState() => feedScreenState();
}


class feedScreenState extends State<feedScreen> {
  @override

  Widget degustacion(degustacion){
    return Column(
      children: [
        Stack(
          children: [
                AspectRatio(aspectRatio: 9/16,
                  child: Container(
                    color: Colors.red,
                    width: double.infinity,
                    height: double.infinity,
                ),
                ),
            Positioned(
            left: MediaQuery.of(context).size.height*0.01,
            top:  MediaQuery.of(context).size.height*0.01,
            child: ListView(
              children: [
               Text(degustacion.nombre),
               Text(degustacion.tipo[0]),
               Text(degustacion.descripcion),
               Text(degustacion.restaurante),
               Text(degustacion.fecha),
              ]
            ),
            ),
          ]
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
      children: degustaciones.isEmpty ? [const Text("No hay degustaciones")] : degustaciones,
    );
  }

}
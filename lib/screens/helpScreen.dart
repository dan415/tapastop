
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/globals.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  HelpScreenState createState() => HelpScreenState();
}


class HelpScreenState extends State<HelpScreen> {
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
        body: Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Column(children: [
                Logo.build(context),
                const Text("Si tiene alguna duda, puede mandar un correo a tapastop.grupo62@gmail.com")
              ])),
        ));
  }

}
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/globals.dart';
import '../utils/navigator.dart';

class GalardonScreen extends StatefulWidget {
  const GalardonScreen({super.key});

  @override
  GalardonScreenState createState() => GalardonScreenState();
}


class GalardonScreenState extends State<GalardonScreen> {
  //TODO GET GALARDONES
  List<Map<String, String>>? galardones;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:
      Container(
      color: Colors.white,
      padding: Paddings.containerPadding(screenSize: MediaQuery.of(context).size),
      child: Column(children: [
        Container(
            height: 75,
            alignment: Alignment.bottomCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            "Galardones",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
        Expanded(
          child: _galardonList(galardones)
          ),
      ]),
    ));
  }

  Widget _galardonList(galardones) {
    List<Widget> galardonList = [];
    if (galardones != null) {
      for (var galardon in galardones) {
        galardonList.add(
            _galardonListItem(
                id: galardonList.length,
                name: galardon.username,
                descripcion: galardon.id
            )
        );
        galardonList.add(const Divider(
          thickness: 2,
        ));
      }
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        children: galardonList.isNotEmpty ? galardonList : [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              "No tienes galardones",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          )
          ],
      ),
    );
  }

  int _higlightedRow = -1;
  _higlightRow(int row) => (TapDownDetails details) {
    setState(() {
      _higlightedRow = row;
    });
  };

  _dehighliteRow({Widget? page}) => () {
    setState(() {
      _higlightedRow = -1;
    });
    if (page != null) Navigator.push(context, MyNavigator.createRoute(page, isAnimated: true));
  };

  Widget _galardonListItem({required id, required String name, required String descripcion}) {
    return Container(
      color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTapDown: _higlightRow(id),
                onTapCancel: _dehighliteRow(),
                onTap: _dehighliteRow(page: null),
                child: Container(
                  decoration: _decor(_higlightedRow == id),
                  child: Column(
                    children: [
                      Text(name),
                      Text(descripcion)
                    ],
                  )
                ),
              ),
            ),
          ],
        ));
  }

  BoxDecoration _decor(bool activated) {
    return (activated)
        ? BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))
        : BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10));
  }

  int _droped = -1;
  _drop(int id) {
    setState(() {
      _droped = id;
    });
  }




}
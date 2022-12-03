import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tapastop/screens/GalardonScreen.dart';
import 'package:tapastop/screens/SearchScreen.dart';
import 'package:tapastop/screens/feedScreen.dart';
import 'package:tapastop/screens/helpScreen.dart';
import 'package:tapastop/screens/profileScreen.dart';
import 'package:tapastop/screens/settingScreen.dart';

import '../utils/navigator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}


class HomeScreenState extends State<HomeScreen> {

  Widget appbar(){
    return AppBar();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0), // here the desired height
            child: AppBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              centerTitle: true,
              title: Text("Menu"),
            )
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
      children: [
                        Container(
                          color: Theme.of(context).primaryColorLight,
                          child: GestureDetector(
                            onTap: () => Navigator.push(context, MyNavigator.createRoute(const SearchScreen(), isAnimated: true)),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                                child: Column( children: const [Icon(Icons.search, size: 100,), Text("Buscar")])
                            ),
                          ),
                        ),

                    Container(
                      color: Theme.of(context).primaryColorLight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MyNavigator.createRoute(const ProfileScreen(), isAnimated: true)),
                        child: Container(
                            width: 50,
                            height: 50,
                            child: Column( children: const [Icon(Icons.man, size: 100,), Text("Perfil")])

                        ),
                      ),
                    ),

                    Container(
                      color: Theme.of(context).primaryColorLight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MyNavigator.createRoute(const HelpScreen(), isAnimated: true)),
                        child: Container(
                            width: 50,
                            height: 50,
                            child: Column( children: const [Icon(Icons.help, size: 100,), Text("Ayuda")])

                        ),
                      ),
                    ),

                    Container(
                      color: Theme.of(context).primaryColorLight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MyNavigator.createRoute(const GalardonScreen(), isAnimated: true)),
                        child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Column( children: const [Icon(Icons.check, size: 100,), Text("Galardones")])

                        ),
                      ),
                    ),

                  Container(
                    color: Theme.of(context).primaryColorLight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MyNavigator.createRoute(const feedScreen(), isAnimated: true)),
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Column( children: const [Icon(Icons.food_bank, size: 100,), Text("Degustaciones")])

                      ),
                    ),
                  ),
        Container(
          color: Theme.of(context).primaryColorLight,
          child: GestureDetector(
            onTap: () => Navigator.push(context, MyNavigator.createRoute( AccountPage(), isAnimated: true)),
            child: SizedBox(
                width: 50,
                height: 50,
                child: Column( children: const [Icon(Icons.settings, size: 100,), Text("Ajustes")])

            ),
          ),
        ),
                ],
      )
    );
  }
}
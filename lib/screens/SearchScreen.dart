import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../firebase_operations/databaseAPI.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  List<String> _searchList = [];
  Database db = Database();
  int? filtro = 0;
  String _searchText = "";
  List<Widget> _buildSearchList() {
    return _searchList.map((search) => ListTile(title: Text(search))).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    List<String>? degs;
                    if(filtro == 0) {
                      degs = await db.getDegustaciones();
                      if (degs.contains(_searchText)) {
                        setState(() {
                          _searchList.add(_searchText);
                        });
                    }
                      }
                    else if (filtro == 1){
                      degs = await db.getDegustacionesRestaurante(_searchText);
                      setState(() {
                        _searchList.add(_searchText);
                      });
                    }
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
              child: ListView(
                children: _buildSearchList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///Pesquisa o conteúdo desta variável
  String _search;

  ///Número de buscas incrementais (quantidade de icones para a proxima pagina
  int _offSet = 0;

  /**
   * _getGif busca no site giphy.com as melhores gifs do momento e também
   * permite pesquisar suas gifs
   */
  Future<Map> _getGif() async {
    http.Response response;

    if (_search == null) {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=9LFHhLElFlO17yDG0B6hTLzKXa0t99yG&limit=20&rating=G');
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=9LFHhLElFlO17yDG0B6hTLzKXa0t99yG&q=$_search&limit=19&offset=$_offSet&rating=G&lang=pt');
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getGif().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        //Image
        centerTitle: true,
      ), //AppBar
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise aqui!",
                labelStyle: TextStyle(
                  color: Colors.white,
                ), //TextStyle
                border: OutlineInputBorder(),
              ),
              //InputDecoration
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ), //TextStyle
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offSet = 0;
                });
              },
            ), //TextField,
          ), //Padding
          Expanded(
            child: FutureBuilder(
              future: _getGif(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ), //CircularProgressIndicator
                    ); //Container
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ), //FutureBuilder
          ), //Expanded
        ], //Widget
      ), //Column
    ); //Scaffold
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ), //SliverGridDelegateWithFixedCrossAxisCount
        itemCount: _getCount(snapshot.data['data']),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data['data'].length)
            return GestureDetector(
              child: Image.network(
                snapshot.data['data'][index]['images']['fixed_height']['url'],
                height: 300.0,
                fit: BoxFit.cover,
              ), //Image
            ); //GestureDetector
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ), //Icon
                    Text(
                      "Carregar mais...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                      ), //TextStyle
                    ), //Text
                  ], //Widget
                ), //Column
                onTap: (){
                  setState(() {
                    _offSet += 19;
                  });//setState
                },//onTap
              ), //GestureDetector
            ); //Container
        } //itemBuilder
        ); //GridView
  }
}

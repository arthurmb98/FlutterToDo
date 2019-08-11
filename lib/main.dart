import 'dart:convert';

import 'package:flutter/material.dart';
import 'models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage(){
    items = [];
    // items.add(Item(title: "Item 1", done: false));
    // items.add(Item(title: "Item 2", done: true));
    // items.add(Item(title: "Item 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add(){
    if(newTaskCtrl.text.isEmpty) return;
    
    setState(() {
      widget.items.add(
        Item
        (
          title: newTaskCtrl.text, 
          completed: false,
       ),
     );
     newTaskCtrl.clear();
     save();
    });
  }

  void remove(int index){
    setState(() {
     widget.items.removeAt(index); 
     save();
    });
  }
  

Future fetchData() async {

  var response = await http.get(
          "https://my-json-server.typicode.com/arthurmb98/JsonDataBase/posts"
  );

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    Iterable decoded = json.decode(response.body);
    print(response.body);
    print(decoded);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
       widget.items = result; 
      });

  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    //prefs.clear();
    //prefs.commit();
    if(data != null){
      print(data);
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
       widget.items = result; 
      });
    }

  }

  save() async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState(){
    //load();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index){
          final item = widget.items[index];

          return Dismissible(
            child: CheckboxListTile(
            title: Text(item.title),
            value: item.completed,
            onChanged: (value){
              //print(value);
              setState(() {
               item.completed = value; 
               save();
              });
            },
          ),  
          key: Key(item.title),
          background: Container(
            color: Colors.red.withOpacity(0.2),
          ),
          onDismissed: (direction){
            remove(index);
          },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        ),
      );
  }
}




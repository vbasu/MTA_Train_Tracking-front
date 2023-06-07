import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MTA Subway Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  final String serverUrl = 'http://127.0.0.1:5000';
  String htmlResponse = '';

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonExample(),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   child: const Text('Find upcoming trains'),
            //   onPressed: () {
            //     _getDataFromFlask();
            //   },
            // ),
            // const SizedBox(height: 16),
            // Html(data: htmlResponse),
          ],
        ),
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  // static List<String> list = <String>[
  //   'Fulton St',
  //   'Lexington Av/63 St',
  //   'Times Sq-42 St',
  //   '72 St'
  // ];
  String dropdownValue = 'Fulton St';
  static List<String> stations = [];
  final String serverUrl = 'http://127.0.0.1:5000';
  String htmlResponse = '';

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    List<String> stationData = await _getStationData();
    setState(() {
      stations = stationData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DropdownButton<String>(
        value: dropdownValue,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (String? value) {
          setState(() {
            dropdownValue = value!;
          });
          _getTrainData();
        },
        items: stations.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      Html(data: htmlResponse),
    ]);
  }

  Future<void> _getTrainData() async {
    var url = Uri.parse('$serverUrl/train_data?station=$dropdownValue');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      print('Data received successfully: ${response.body}');
      // Handle the response data
      setState(() {
        htmlResponse = response.body;
      });
    } else {
      print('Data retrieval failed with status: ${response.statusCode}');
    }
  }

  Future<List<String>> _getStationData() async {
    var url = Uri.parse('$serverUrl/station_data');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final stationData = json.decode(response.body);
      List<String> data = List<String>.from(stationData['data']);
      return data;
    } else {
      print('Data retrieval failed with status: ${response.statusCode}');
    }
    return <String>[];
  }
}

import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:functional_listener/functional_listener.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _counter = ValueNotifier<int>(0);
  final _textInput = ValueNotifier<String>('');

  ValueNotifier<String> _counterEvenValuesAsString;
  ValueNotifier<String> _debouncedUpperCaseText;

  ValueListenable<String> get counterEvenValuesAsString =>
      _counterEvenValuesAsString;
  ValueListenable<String> get debouncedUpperCaseText => _debouncedUpperCaseText;

  @override
  void initState() {
    _debouncedUpperCaseText = _textInput
        .debounce(const Duration(milliseconds: 500))
        .map((s) => s.toLowerCase());
    _counterEvenValuesAsString =
        _counter.where((x) => x.isEven).map<String>((x) => x.toString());
    super.initState();
  }

  void _incrementCounter() {
    _counter.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            ValueListenableBuilder<String>(
              /// simple example to use map
              valueListenable: counterEvenValuesAsString,
              builder: (context, value, _) => Text(
                value,
                style: Theme.of(context).textTheme.headline4,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

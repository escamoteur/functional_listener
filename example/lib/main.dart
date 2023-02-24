import 'package:flutter/material.dart';
import 'package:functiona_listerner_example/model.dart';
import 'package:functional_listener/functional_listener.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'functional_listener Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

///
/// I didn't want to use any Locator or InheritedWidget
/// in this example. In a real project I wouldn't use
/// a global variable for this.
final theModel = Model();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Type any value here'),
              SizedBox(height: 16),
              TextField(
                onChanged: theModel.updateText,
              ),
              SizedBox(height: 16),
              Text(
                  'The following field displays the entered text in uppercase.\n'
                  'It gets only updated if the user pauses its input for at lease 500ms'),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<String>(
                    valueListenable: theModel.debouncedUpperCaseText,
                    builder: (context, s, _) => Text(s),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'This counter only displays even Numbers',
                textAlign: TextAlign.center,
              ),
              ValueListenableBuilder<String>(
                valueListenable: theModel.counterEvenValuesAsString,
                builder: (context, value, _) => Text(value,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center),
              ),
              Text(
                'The following field gets updated whenever one of the others changes:',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<String>(
                /// Simple example of `combineLatest` without an wrapper class
                /// because the combiner function combines both values to one single string
                valueListenable: theModel.debouncedUpperCaseText.combineLatest(
                    theModel.counterEvenValuesAsString,
                    (s1, dynamic s2) => '$s1:$s2'),
                builder: (context, value, _) => Text(value,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: theModel.incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

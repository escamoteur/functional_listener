import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:functional_listener/functional_listener.dart';
import 'package:watch_it/watch_it.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _functionalListeners = <MyAbstractClass>[];
  final _normalListeners = <MyAbstractClass>[];
  final _random = Random();

  late MyAbstractClass _selectedListenable;

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < 5; i++) {
      _functionalListeners.add(MyFunctionalListenerClass());
      _normalListeners.add(MyNormalListenerClass());
    }

    _selectedListenable = _functionalListeners.first;
  }

  void _nextFunctionalListener() {
    setState(() {
      _selectedListenable = _functionalListeners[_random.nextInt(5)];
      print(_selectedListenable.hashCode);
      _generateAndSetRandomValue();
    });
  }

  void _nextNormalListener() {
    setState(() {
      _selectedListenable = _normalListeners[_random.nextInt(5)];
      _generateAndSetRandomValue();
    });
  }

  void _generateAndSetRandomValue() {
    final isFirst = Random().nextBool();
    final value = Random().nextInt(1 << 31);
    print(
      'setting $value to ${isFirst ? 'notifier1' : 'notifier2'} in $_selectedListenable',
    );

    if (isFirst) {
      _selectedListenable.setNotifier1(value);
    } else {
      _selectedListenable.setNotifier2(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _nextFunctionalListener,
            label: Text('Next functional listener'),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton.extended(
            onPressed: _nextNormalListener,
            label: Text('Next normal listener'),
          ),
        ],
      ),
      body: Center(
        child: MyChild(
          listenable: _selectedListenable,
        ),
      ),
    );
  }
}

class MyChild extends StatelessWidget with WatchItMixin {
  const MyChild({
    super.key,
    required this.listenable,
  });

  final MyAbstractClass listenable;

  @override
  Widget build(BuildContext context) {
    final value = watch(listenable.listenable).value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value.toString()),
        Text(listenable.toString()),
        ElevatedButton(
          onPressed: () {
            final isFirst = Random().nextBool();
            print('setting value to ${isFirst ? 'notifier1' : 'notifier2'}');

            if (isFirst) {
              listenable.setNotifier1(Random().nextInt(1 << 31));
            } else {
              listenable.setNotifier2(Random().nextInt(1 << 31));
            }
          },
          child: const Text('Set random value to random notifier'),
        ),
      ],
    );
  }
}

abstract class MyAbstractClass {
  ValueListenable<int> get listenable;

  void setNotifier1(int value);
  void setNotifier2(int value);

  @override
  String toString() {
    return '$runtimeType#$hashCode';
  }
}

class MyFunctionalListenerClass extends MyAbstractClass {
  MyFunctionalListenerClass() {
    listenable = _notifier1.mergeWith([_notifier2]);
  }

  final _notifier1 = ValueNotifier(0);
  final _notifier2 = ValueNotifier(0);

  @override
  late final ValueListenable<int> listenable;

  @override
  void setNotifier1(int value) {
    _notifier1.value = value;
  }

  @override
  void setNotifier2(int value) {
    _notifier2.value = value;
  }
}

class MyNormalListenerClass extends MyAbstractClass {
  MyNormalListenerClass() {
    _notifier1.addListener(_onNotifier1Changed);
    _notifier2.addListener(_onNotifier2Changed);

    listenable = ValueNotifier(0);
  }

  final _notifier1 = ValueNotifier(0);
  final _notifier2 = ValueNotifier(0);

  void _onNotifier1Changed() {
    listenable.value = _notifier1.value;
  }

  void _onNotifier2Changed() {
    listenable.value = _notifier2.value;
  }

  @override
  late final ValueNotifier<int> listenable;

  @override
  void setNotifier1(int value) {
    _notifier1.value = value;
  }

  @override
  void setNotifier2(int value) {
    _notifier2.value = value;
  }
}

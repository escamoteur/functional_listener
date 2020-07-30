import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:functional_listener/functional_listener.dart';

void main() {
  test('Map Test', () {
    final sourceListenable = ValueNotifier<int>(0);
    final destListenable = sourceListenable.map<String>((x) => x.toString());

    String destValue;
    // ignore: prefer_function_declarations_over_variables
    final handler = () => destValue = destListenable.value;
    destListenable.addListener(handler);

    sourceListenable.value = 42;

    expect(destListenable.value, '42');
    expect(destValue, '42');

    destListenable.removeListener(handler);

    sourceListenable.value = 4711;

    expect(destValue, '42');
  });

  test('Listen Test', () {
    final listenable = ValueNotifier<int>(0);

    int destValue;
    final subscription = listenable.listen((x, _) => destValue = x);

    listenable.value = 42;

    expect(destValue, 42);

    subscription.cancel();

    listenable.value = 4711;

    expect(destValue, 42);
  });

  test('Listen Test with interal cancel', () {
    final listenable = ValueNotifier<int>(0);

    int destValue;
    listenable.listen((x, subscription) {
      if (x == 42) {
        subscription.cancel();
      }
      destValue = x;
    });

    listenable.value = 42;

    expect(destValue, 42);

    listenable.value = 4711;

    expect(destValue, 42);
  });
  test('Where Test', () {
    final listenable = ValueNotifier<int>(0);

    final destValues = <int>[];
    final subscription =
        listenable.where((x) => x.isEven).listen((x, _) => destValues.add(x));

    listenable.value = 42;
    listenable.value = 43;
    listenable.value = 44;
    listenable.value = 45;

    expect(destValues, [42, 44]);

    subscription.cancel();

    listenable.value = 46;

    expect(destValues.length, 2);
  });

  test('Debounce Test', () async {
    final listenable = ValueNotifier<int>(0);

    final destValues = <int>[];
    listenable
        .debounce(const Duration(milliseconds: 500))
        .listen((x, _) => destValues.add(x));

    listenable.value = 42;
    await Future.delayed(const Duration(milliseconds: 100));
    listenable.value = 43;
    await Future.delayed(const Duration(milliseconds: 100));
    listenable.value = 44;
    await Future.delayed(const Duration(milliseconds: 350));
    listenable.value = 45;
    await Future.delayed(const Duration(milliseconds: 550));
    listenable.value = 46;

    expect(destValues, [42, 45, 46]);
  });

  test('combineLatest Test', () {
    final listenable1 = ValueNotifier<int>(0);
    final listenable2 = ValueNotifier<String>('Start');

    final destValues = <StringIntWrapper>[];
    final subscription = listenable1
        .combineLatest<String, StringIntWrapper>(
            listenable2, (i, s) => StringIntWrapper(s, i))
        .listen((x, _) {
      destValues.add(x);
    });

    listenable1.value = 42;
    listenable1.value = 43;
    listenable2.value = 'First';
    listenable1.value = 45;

    expect(destValues[0].toString(), 'Start:42');
    expect(destValues[1].toString(), 'Start:43');
    expect(destValues[2].toString(), 'First:43');
    expect(destValues[3].toString(), 'First:45');

    subscription.cancel();

    listenable1.value = 46;

    expect(destValues.length, 4);
  });
}

class StringIntWrapper {
  final String s;
  final int i;

  StringIntWrapper(this.s, this.i);

  @override
  String toString() {
    return '$s:$i';
  }
}

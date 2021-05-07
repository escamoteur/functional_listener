import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:functional_listener/functional_listener.dart';

void main() {
  test('Map Test', () {
    final sourceListenable = ValueNotifier<int>(0);
    final destListenable = sourceListenable.map<String>((x) => x.toString());

    String? destValue;
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

    int? destValue;
    final subscription = listenable.listen((x, _) => destValue = x);

    listenable.value = 42;

    expect(destValue, 42);

    subscription.cancel();

    listenable.value = 4711;

    expect(destValue, 42);
  });

  test('Listen Test with interal cancel', () {
    final listenable = ValueNotifier<int>(0);

    int? destValue;
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

    expect(destValues, [45]);
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

  test('combineLatest3 Test', () {
    final listenable1 = ValueNotifier<String>('InitVal1');
    final listenable2 = ValueNotifier<String>('InitVal2');
    final listenable3 = ValueNotifier<String>('InitVal3');

    final destValues = <String>[];
    final subscription = listenable1
        .combineLatest3<String, String, String>(
            listenable2, listenable3, (i, j, s) => "$i:$j:$s")
        .listen((x, _) {
      destValues.add(x);
    });

    listenable1.value = '42';
    listenable1.value = '43';
    listenable2.value = 'First';
    listenable3.value = 'NewVal3';
    listenable1.value = '45';

    expect(destValues[0].toString(), '42:InitVal2:InitVal3');
    expect(destValues[1].toString(), '43:InitVal2:InitVal3');
    expect(destValues[2].toString(), '43:First:InitVal3');
    expect(destValues[3].toString(), '43:First:NewVal3');
    expect(destValues[4].toString(), '45:First:NewVal3');

    subscription.cancel();

    listenable1.value = '46';

    expect(destValues.length, 5);
  });

  test('combineLatest4 Test', () {
    final listenable1 = ValueNotifier<String>('InitVal1');
    final listenable2 = ValueNotifier<String>('InitVal2');
    final listenable3 = ValueNotifier<String>('InitVal3');
    final listenable4 = ValueNotifier<String>('InitVal4');

    final destValues = <String>[];
    final subscription = listenable1
        .combineLatest4<String, String, String, String>(
            listenable2, listenable3, listenable4, (i, j, k, s) => "$i:$j:$k:$s")
        .listen((x, _) {
      destValues.add(x);
    });

    listenable1.value = '42';
    listenable1.value = '43';
    listenable2.value = 'First';
    listenable3.value = 'NewVal3';
    listenable4.value = 'NewVal4';
    listenable1.value = '45';

    expect(destValues[0].toString(), '42:InitVal2:InitVal3:InitVal4');
    expect(destValues[1].toString(), '43:InitVal2:InitVal3:InitVal4');
    expect(destValues[2].toString(), '43:First:InitVal3:InitVal4');
    expect(destValues[3].toString(), '43:First:NewVal3:InitVal4');
    expect(destValues[4].toString(), '43:First:NewVal3:NewVal4');
    expect(destValues[5].toString(), '45:First:NewVal3:NewVal4');

    subscription.cancel();

    listenable1.value = '46';

    expect(destValues.length, 6);
  });

  test('mergeWith Test', () {
    final listenable1 = ValueNotifier<int>(0);
    final listenable2 = ValueNotifier<int>(0);
    final listenable3 = ValueNotifier<int>(0);
    final listenable4 = ValueNotifier<int>(0);

    final destValues = <int>[];
    final subscription = listenable1
        .mergeWith([listenable2, listenable3, listenable4]).listen((x, _) {
      destValues.add(x);
    });

    listenable2.value = 42;
    listenable1.value = 43;
    listenable4.value = 44;
    listenable3.value = 45;
    listenable1.value = 46;

    expect(destValues[0], 42);
    expect(destValues[1], 43);
    expect(destValues[2], 44);
    expect(destValues[3], 45);
    expect(destValues[4], 46);

    subscription.cancel();

    listenable1.value = 47;

    expect(destValues.length, 5);
  });

  test('mergeWith unsubscribe/resubscribe Test', () {
    final listenable1 = ValueNotifier<int>(0);
    final listenable2 = ValueNotifier<int>(0);
    final listenable3 = ValueNotifier<int>(0);

    final destValues = <int>[];
    final mergedListenable = listenable1.mergeWith([
      listenable2,
      listenable3,
    ]);
    var subscription = mergedListenable.listen((x, _) {
      destValues.add(x);
    });

    listenable2.value = 42;
    listenable1.value = 43;
    listenable3.value = 45;
    listenable1.value = 46;

    expect(destValues[0], 42);
    expect(destValues[1], 43);
    expect(destValues[2], 45);
    expect(destValues[3], 46);

    subscription.cancel();

    listenable1.value = 47;

    expect(destValues.length, 4);

    destValues.clear();
    subscription = mergedListenable.listen((x, _) {
      destValues.add(x);
    });

    listenable1.value = 42;

    expect(destValues[0], 42);
  });

  test('CustomValueNotifier normal behaviour', () {
    final notifier = CustomValueNotifier<int>(4711);
    int val = 0;
    int callCount = 0;

    notifier.addListener(() {
      val = notifier.value;
      callCount++;
    });

    expect(notifier.value, 4711);
    notifier.value = 4711;
    expect(notifier.value, 4711);
    expect(val, 0);
    notifier.value = 42;
    expect(notifier.value, 42);
    expect(val, 42);
    expect(callCount, 1);
  });
  test('CustomValueNotifier a manual notify', () {
    final notifier =
        CustomValueNotifier<int>(4711, mode: CustomNotifierMode.manual);
    int val = 0;
    int callCount = 0;

    notifier.addListener(() {
      val = notifier.value;
      callCount++;
    });

    expect(notifier.value, 4711);
    notifier.value = 4711;
    expect(notifier.value, 4711);
    expect(val, 0);
    notifier.value = 42;
    expect(notifier.value, 42);
    expect(val, 0);
    expect(callCount, 0);
    notifier.notifyListeners();
    expect(val, 42);
    expect(callCount, 1);
  });
  test('CustomValueNotifier  always notify', () {
    final notifier =
        CustomValueNotifier<int>(4711, mode: CustomNotifierMode.always);
    int val = 0;
    int callCount = 0;

    notifier.addListener(() {
      val = notifier.value;
      callCount++;
    });

    expect(notifier.value, 4711);
    notifier.value = 4711;
    expect(notifier.value, 4711);
    expect(val, 4711);
    notifier.value = 42;
    expect(notifier.value, 42);
    expect(val, 42);
    expect(callCount, 2);
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

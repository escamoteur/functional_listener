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

  test('Select Test', () {
    final sourceListenable =
        ValueNotifier<StringIntWrapper>(StringIntWrapper("fiz", 0));
    final stringDestListenable = sourceListenable.select<String>((x) => x.s);

    String? stringDestValue;
    // ignore: prefer_function_declarations_over_variables
    final stringHandler = () => stringDestValue = stringDestListenable.value;

    stringDestListenable.addListener(stringHandler);

    sourceListenable.value = StringIntWrapper("fiz", 1);

    expect(stringDestListenable.value, 'fiz');
    expect(stringDestValue, null);

    sourceListenable.value = StringIntWrapper("buzz", 1);

    expect(stringDestListenable.value, 'buzz');
    expect(stringDestValue, 'buzz');

    stringDestListenable.removeListener(stringHandler);

    sourceListenable.value = StringIntWrapper("fiz-buzz", 2);

    expect(stringDestValue, 'buzz');
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

  test('async Test', () async {
    final listenable = ValueNotifier<int>(0);

    final destValues = <int>[];
    listenable.async().listen((x, _) => destValues.add(x));

    listenable.value = 42;
    expect(destValues, []);
    await Future.delayed(const Duration(milliseconds: 100));

    expect(destValues, [42]);
  });

  test('combineLatest Test', () {
    final listenable1 = ValueNotifier<int>(0);
    final listenable2 = ValueNotifier<String>('Start');

    final destValues = <StringIntWrapper>[];
    var subscription = listenable1
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

    destValues.clear();
    subscription = listenable1
        .combineLatest<String, StringIntWrapper>(
            listenable2, (i, s) => StringIntWrapper(s, i))
        .listen((x, _) {
      destValues.add(x);
    });
    listenable1.value = 47;
    expect(destValues[0].toString(), 'First:47');
    expect(destValues.length, 1);
  });

  test('combineLatest3 Test', () {
    final listenable1 = ValueNotifier<String>('InitVal1');
    final listenable2 = ValueNotifier<String>('InitVal2');
    final listenable3 = ValueNotifier<String>('InitVal3');

    final destValues = <String>[];
    var subscription = listenable1
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

    destValues.clear();
    subscription = listenable1
        .combineLatest3<String, String, String>(
            listenable2, listenable3, (i, j, s) => "$i:$j:$s")
        .listen((x, _) {
      destValues.add(x);
    });
    listenable1.value = "47";
    expect(destValues[0].toString(), '47:First:NewVal3');
    expect(destValues.length, 1);
  });

  test('combineLatest4 Test', () {
    final listenable1 = ValueNotifier<String>('InitVal1');
    final listenable2 = ValueNotifier<String>('InitVal2');
    final listenable3 = ValueNotifier<String>('InitVal3');
    final listenable4 = ValueNotifier<String>('InitVal4');

    final destValues = <String>[];
    final subscription = listenable1
        .combineLatest4<String, String, String, String>(listenable2,
            listenable3, listenable4, (i, j, k, s) => "$i:$j:$k:$s")
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

  test('combineLatest5 Test', () {
    final listenable1 = ValueNotifier<String>('InitVal1');
    final listenable2 = ValueNotifier<String>('InitVal2');
    final listenable3 = ValueNotifier<String>('InitVal3');
    final listenable4 = ValueNotifier<String>('InitVal4');
    final listenable5 = ValueNotifier<String>('InitVal5');

    final destValues = <String>[];
    final subscription = listenable1
        .combineLatest5<String, String, String, String, String>(
            listenable2,
            listenable3,
            listenable4,
            listenable5,
            (i, j, k, l, s) => "$i:$j:$k:$l:$s")
        .listen((x, _) {
      destValues.add(x);
    });

    listenable1.value = '42';
    listenable1.value = '43';
    listenable2.value = 'First';
    listenable3.value = 'NewVal3';
    listenable4.value = 'NewVal4';
    listenable5.value = 'NewVal5';
    listenable1.value = '45';

    expect(destValues[0].toString(), '42:InitVal2:InitVal3:InitVal4:InitVal5');
    expect(destValues[1].toString(), '43:InitVal2:InitVal3:InitVal4:InitVal5');
    expect(destValues[2].toString(), '43:First:InitVal3:InitVal4:InitVal5');
    expect(destValues[3].toString(), '43:First:NewVal3:InitVal4:InitVal5');
    expect(destValues[4].toString(), '43:First:NewVal3:NewVal4:InitVal5');
    expect(destValues[5].toString(), '43:First:NewVal3:NewVal4:NewVal5');
    expect(destValues[6].toString(), '45:First:NewVal3:NewVal4:NewVal5');

    subscription.cancel();

    listenable1.value = '46';

    expect(destValues.length, 7);
  });

  test('combineLatest6 Test', () {
    final listenable1 = ValueNotifier<String>('Init1');
    final listenable2 = ValueNotifier<String>('Init2');
    final listenable3 = ValueNotifier<String>('Init3');
    final listenable4 = ValueNotifier<String>('Init4');
    final listenable5 = ValueNotifier<String>('Init5');
    final listenable6 = ValueNotifier<String>('Init6');

    final destValues = <String>[];
    final subscription = listenable1
        .combineLatest6<String, String, String, String, String, String>(
            listenable2,
            listenable3,
            listenable4,
            listenable5,
            listenable6,
            (i, j, k, l, m, s) => "$i:$j:$k:$l:$m:$s")
        .listen((x, _) {
      destValues.add(x);
    });

    listenable1.value = '42';
    listenable1.value = '43';
    listenable2.value = 'First';
    listenable3.value = 'New3';
    listenable4.value = 'New4';
    listenable5.value = 'New5';
    listenable6.value = 'New6';
    listenable1.value = '45';

    expect(destValues[0].toString(), '42:Init2:Init3:Init4:Init5:Init6');
    expect(destValues[1].toString(), '43:Init2:Init3:Init4:Init5:Init6');
    expect(destValues[2].toString(), '43:First:Init3:Init4:Init5:Init6');
    expect(destValues[3].toString(), '43:First:New3:Init4:Init5:Init6');
    expect(destValues[4].toString(), '43:First:New3:New4:Init5:Init6');
    expect(destValues[5].toString(), '43:First:New3:New4:New5:Init6');
    expect(destValues[6].toString(), '43:First:New3:New4:New5:New6');
    expect(destValues[7].toString(), '45:First:New3:New4:New5:New6');

    subscription.cancel();

    listenable1.value = '46';

    expect(destValues.length, 8);
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

  test('no double chain subscriptions', () {
    final notifier =
        CustomValueNotifier<int>(0, mode: CustomNotifierMode.always);
    int callCount = 0;
    notifier.listen((v, _) {
      callCount++;
    });

    int chainCallCount = 0;
    final mapNotifier = notifier.map((v) {
      chainCallCount++;
      return v + 1;
    });

    int mapCallCount = 0;
    mapNotifier.listen((v, _) {
      mapCallCount++;
    });

    notifier.value = 1;

    expect(callCount, 1);
    expect(mapNotifier.value, 2);
    expect(mapCallCount, 1);
    expect(chainCallCount, 2); // 1 on init, 1 after notifier.value = 1;
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

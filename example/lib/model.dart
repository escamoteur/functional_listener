import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:functional_listener/functional_listener.dart';

class Model {
  ValueNotifier<StringIntWrapper>? _combined =
      ValueNotifier(StringIntWrapper('', 0));

  late ValueNotifier<String> _counterEvenValuesAsString;
  late ValueNotifier<String> _debouncedUpperCaseText;

  /// We only make the `ValueListenable` interface public
  /// so that none outside the Model class can modify the values
  ValueListenable<String> get counterEvenValuesAsString =>
      _counterEvenValuesAsString;
  ValueListenable<String> get debouncedUpperCaseText => _debouncedUpperCaseText;

  Model() {
    _debouncedUpperCaseText = _combined! // select only string changes
        .select((model) => model.s)
        .debounce(const Duration(milliseconds: 500))
        .map((s) => s.toUpperCase()) as ValueNotifier<String>;
    _counterEvenValuesAsString = _combined! // select only int changes
        .select((model) => model.i)
        .where((x) => x.isEven)
        .map<String>((x) => x.toString()) as ValueNotifier<String>;
  }

  void incrementCounter() {
    _combined!.value =
        StringIntWrapper(_combined!.value.s, _combined!.value.i + 1);
  }

  void updateText(String s) {
    _combined!.value = StringIntWrapper(s, _combined!.value.i);
  }

  void dispose() async {
    final storage = <List<int>>[];

    void allocateMemory() {
      storage.add(List.generate(3000, (n) => n));
      if (storage.length > 1000) {
        storage.removeAt(0);
      }
    }

    _combined!.dispose();
    _combined = null;
    // _counterEvenV    for (var i = 0; i < 300; i++) {
    allocateMemory();
    await Future.delayed(const Duration(milliseconds: 1000));
    storage.clear();
    await Future.delayed(const Duration(milliseconds: 10));
    NativeRuntime.writeHeapSnapshotToFile('dump.heapsnapshot');

    /// valuesAsString.dispose();
    // _debouncedUpperCaseText.dispose();
  }
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

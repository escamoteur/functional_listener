import 'package:flutter/foundation.dart';
import 'package:functional_listener/functional_listener.dart';

class Model {
  final _counter = ValueNotifier<int>(0);
  final _textInput = ValueNotifier<String>('');

  /// We only make the `ValueListenable` interface public
  /// so that noone outside the Model class can modify the values
  ValueListenable<String> get counterEvenValuesAsString =>
      _counter.where((x) => x.isEven).map<String>((x) => x.toString());

  ValueListenable<String> get debouncedUpperCaseText => _textInput
      .debounce(const Duration(milliseconds: 500))
      .map((s) => s.toUpperCase());

  void incrementCounter() {
    _counter.value++;
  }

  void updateText(String s) {
    _textInput.value = s;
  }
}

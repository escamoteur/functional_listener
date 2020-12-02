import 'package:flutter/foundation.dart';
import 'package:functional_listener/functional_listener.dart';

class Model {
  final _counter = ValueNotifier<int>(0);
  final _textInput = ValueNotifier<String>('');

  late ValueNotifier<String> _counterEvenValuesAsString;
  late ValueNotifier<String> _debouncedUpperCaseText;

  /// We only make the `ValueListenable` interface public
  /// so that noone outside the Model class can modify the values
  ValueListenable<String> get counterEvenValuesAsString =>
      _counterEvenValuesAsString;
  ValueListenable<String> get debouncedUpperCaseText => _debouncedUpperCaseText;

  Model() {
    _debouncedUpperCaseText = _textInput
        .debounce(const Duration(milliseconds: 500))
        .map((s) => s.toUpperCase()) as ValueNotifier<String>;
    _counterEvenValuesAsString = _counter
        .where((x) => x.isEven)
        .map<String>((x) => x.toString()) as ValueNotifier<String>;
  }

  void incrementCounter() {
    _counter.value++;
  }

  void updateText(String s) {
    _textInput.value = s;
  }
}

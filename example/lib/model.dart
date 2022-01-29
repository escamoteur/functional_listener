import 'package:flutter/foundation.dart';
import 'package:functional_listener/functional_listener.dart';

class Model {

  final  _combined = ValueNotifier(StringIntWrapper('',0));

  late ValueNotifier<String> _counterEvenValuesAsString;
  late ValueNotifier<String> _debouncedUpperCaseText;

  /// We only make the `ValueListenable` interface public
  /// so that none outside the Model class can modify the values
  ValueListenable<String> get counterEvenValuesAsString =>
      _counterEvenValuesAsString;
  ValueListenable<String> get debouncedUpperCaseText => _debouncedUpperCaseText;

  Model() {
    _debouncedUpperCaseText = _combined // select only string changes
        .select((model) => model.s)
        .debounce(const Duration(milliseconds: 500))
        .map((s) => s.toUpperCase()) as ValueNotifier<String>;
    _counterEvenValuesAsString =_combined // select only int changes
        .select((model) => model.i)
        .where((x) => x.isEven)
        .map<String>((x) => x.toString()) as ValueNotifier<String>;
  }

  void incrementCounter() {
    _combined.value = StringIntWrapper(_combined.value.s, _combined.value.i+1);
  }

  void updateText(String s) {
    _combined.value = StringIntWrapper(s, _combined.value.i);
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

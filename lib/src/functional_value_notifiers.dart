import 'dart:async';

import 'package:flutter/foundation.dart';

/// These classes are used to implement the functional_listener implementation
///
abstract class FunctionalValueNotifier<TIn, TOut> extends ValueNotifier<TOut> {
  final ValueListenable<TIn> previousInChain;
  VoidCallback internalHandler;

  FunctionalValueNotifier(
    TOut initialValue,
    this.previousInChain,
  ) : super(initialValue);

  @override
  void removeListener(VoidCallback listener) {
    if (!hasListeners) {
      previousInChain.removeListener(internalHandler);
    }
    super.removeListener(listener);
  }

  @override
  void dispose() {
    previousInChain.removeListener(internalHandler);
    super.dispose();
  }
}

class MapValueNotifier<TIn, TOut> extends FunctionalValueNotifier<TIn, TOut> {
  TOut Function(TIn) transformation;

  MapValueNotifier(
    TOut initialValue,
    ValueListenable<TIn> previousInChain,
    this.transformation,
  ) : super(initialValue, previousInChain) {
    internalHandler = () {
      value = transformation(previousInChain.value);
    };
    previousInChain.addListener(internalHandler);
  }
}

class WhereValueNotifier<T> extends FunctionalValueNotifier<T, T> {
  bool Function(T) selector;

  WhereValueNotifier(
    T initialValue,
    ValueListenable<T> previousInChain,
    this.selector,
  ) : super(initialValue, previousInChain) {
    internalHandler = () {
      if (selector(previousInChain.value)) {
        value = previousInChain.value;
      }
    };
    previousInChain.addListener(internalHandler);
  }
}

class DebouncedValueNotifier<T> extends FunctionalValueNotifier<T, T> {
  Timer debounceTimer;
  Duration debounceDuration;

  DebouncedValueNotifier(
    T initialValue,
    ValueListenable<T> previousInChain,
    this.debounceDuration,
  ) : super(initialValue, previousInChain) {
    internalHandler = () {
      if (debounceTimer == null) {
        debounceTimer = Timer(debounceDuration, () => debounceTimer = null);
        value = previousInChain.value;
      }
    };
    previousInChain.addListener(internalHandler);
  }
}

typedef CombiningFunction2<TIn1, TIn2, TOut> = TOut Function(TIn1, TIn2);

class CombiningValueNotifier<TIn1, TIn2, TOut> extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final CombiningFunction2<TIn1, TIn2, TOut> combiner;
  VoidCallback internalHandler;

  CombiningValueNotifier(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.combiner,
  ) : super(initialValue) {
    internalHandler =
        () => value = combiner(previousInChain1.value, previousInChain2.value);
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
    }
    super.removeListener(listener);
  }

  @override
  void dispose() {
    previousInChain1.removeListener(internalHandler);
    previousInChain2.removeListener(internalHandler);
    super.dispose();
  }
}

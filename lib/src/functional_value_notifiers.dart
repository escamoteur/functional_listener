import 'dart:async';

import 'package:flutter/foundation.dart';

/// These classes are used to implement the functional_listener implementation
///
abstract class FunctionalValueNotifier<TIn, TOut> extends ValueNotifier<TOut> {
  final ValueListenable<TIn> previousInChain;
  late VoidCallback internalHandler;

  FunctionalValueNotifier(
    TOut initialValue,
    this.previousInChain,
  ) : super(initialValue);

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain.removeListener(internalHandler);
    }
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
  Timer? debounceTimer;
  Duration debounceDuration;

  DebouncedValueNotifier(
    T initialValue,
    ValueListenable<T> previousInChain,
    this.debounceDuration,
  ) : super(initialValue, previousInChain) {
    internalHandler = () {
      debounceTimer?.cancel();
      debounceTimer = Timer(debounceDuration, () => value = previousInChain.value);
    };
    previousInChain.addListener(internalHandler);
  }
}

typedef CombiningFunction2<TIn1, TIn2, TOut> = TOut Function(TIn1, TIn2);

class CombiningValueNotifier<TIn1, TIn2, TOut> extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final CombiningFunction2<TIn1, TIn2, TOut> combiner;
  late VoidCallback internalHandler;

  CombiningValueNotifier(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.combiner,
  ) : super(initialValue) {
    internalHandler = () => value = combiner(previousInChain1.value, previousInChain2.value);
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
    }
  }

  @override
  void dispose() {
    previousInChain1.removeListener(internalHandler);
    previousInChain2.removeListener(internalHandler);
    super.dispose();
  }
}

typedef CombiningFunction3<TIn1, TIn2, TIn3, TOut> = TOut Function(
    TIn1, TIn2, TIn3);

class CombiningValueNotifier3<TIn1, TIn2, TIn3, TOut>
    extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final ValueListenable<TIn3> previousInChain3;
  final CombiningFunction3<TIn1, TIn2, TIn3, TOut> combiner;
  late VoidCallback internalHandler;

  CombiningValueNotifier3(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.previousInChain3,
    this.combiner,
  ) : super(initialValue) {
    internalHandler = () => value = combiner(
          previousInChain1.value,
          previousInChain2.value,
          previousInChain3.value,
        );
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
    previousInChain3.addListener(internalHandler);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
      previousInChain3.removeListener(internalHandler);
    }
  }

  @override
  void dispose() {
    previousInChain1.removeListener(internalHandler);
    previousInChain2.removeListener(internalHandler);
    previousInChain3.removeListener(internalHandler);
    super.dispose();
  }
}

typedef CombiningFunction4<TIn1, TIn2, TIn3, TIn4, TOut> = TOut Function(
    TIn1, TIn2, TIn3, TIn4);

class CombiningValueNotifier4<TIn1, TIn2, TIn3, TIn4, TOut>
    extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final ValueListenable<TIn3> previousInChain3;
  final ValueListenable<TIn4> previousInChain4;
  final CombiningFunction4<TIn1, TIn2, TIn3, TIn4, TOut> combiner;
  late VoidCallback internalHandler;

  CombiningValueNotifier4(
      TOut initialValue,
      this.previousInChain1,
      this.previousInChain2,
      this.previousInChain3,
      this.previousInChain4,
      this.combiner,
      ) : super(initialValue) {
    internalHandler = () => value = combiner(
      previousInChain1.value,
      previousInChain2.value,
      previousInChain3.value,
      previousInChain4.value,
    );
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
    previousInChain3.addListener(internalHandler);
    previousInChain4.addListener(internalHandler);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
      previousInChain3.removeListener(internalHandler);
      previousInChain4.removeListener(internalHandler);
    }
  }

  @override
  void dispose() {
    previousInChain1.removeListener(internalHandler);
    previousInChain2.removeListener(internalHandler);
    previousInChain3.removeListener(internalHandler);
    previousInChain4.removeListener(internalHandler);
    super.dispose();
  }
}

class MergingValueNotifiers<T> extends FunctionalValueNotifier<T, T> {
  final List<ValueListenable<T>> mergeWith;
  late List<VoidCallback> disposeFuncs;

  MergingValueNotifiers(
    ValueListenable<T> previousInChain,
    this.mergeWith,
    T initialValue,
  ) : super(initialValue, previousInChain) {
    disposeFuncs = mergeWith.map<VoidCallback>((notifier) {
      final notifyHandler = () => value = notifier.value;
      notifier.addListener(notifyHandler);
      return () => notifier.removeListener(notifyHandler);
    }).toList();
    previousInChain.addListener(internalHandler = () => value = previousInChain.value);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      disposeFuncs.forEach(_callSelf);
    }
  }

  void _callSelf(VoidCallback handler) => handler.call();

  @override
  void dispose() {
    disposeFuncs.forEach(_callSelf);
    super.dispose();
  }
}

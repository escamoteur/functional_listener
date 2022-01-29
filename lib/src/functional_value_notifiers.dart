import 'dart:async';

import 'package:flutter/foundation.dart';

/// These classes are used to implement the functional_listener implementation
///
abstract class FunctionalValueNotifier<TIn, TOut> extends ValueNotifier<TOut> {
  final ValueListenable<TIn> previousInChain;
  late VoidCallback internalHandler;

  @protected
  bool chainInitialized = false;

  FunctionalValueNotifier(
    TOut initialValue,
    this.previousInChain,
  ) : super(initialValue);

  void init(ValueListenable<TIn> previousInChain);

  @protected
  void setupChain() {
    previousInChain.addListener(internalHandler);
    chainInitialized = true;
  }

  @override
  void addListener(VoidCallback listener) {
    if (!chainInitialized) {
      init(previousInChain);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain.removeListener(internalHandler);
      chainInitialized = false;
    }
  }

  @override
  void dispose() {
    previousInChain.removeListener(internalHandler);
    super.dispose();
  }
}

class SelectValueNotifier<TIn, TOut>
    extends FunctionalValueNotifier<TIn, TOut> {
  final TOut Function(TIn) selector;

  SelectValueNotifier(
    TOut initialValue,
    ValueListenable<TIn> previousInChain,
    this.selector,
  ) : super(initialValue, previousInChain) {
    init(previousInChain);
  }

  @override
  void init(ValueListenable<TIn> previousInChain) {
    internalHandler = () {
      final selected = selector(previousInChain.value);
      if (selected != value) {
        value = selected;
      }
    };
    setupChain();
  }
}

class MapValueNotifier<TIn, TOut> extends FunctionalValueNotifier<TIn, TOut> {
  final TOut Function(TIn) transformation;

  MapValueNotifier(
    TOut initialValue,
    ValueListenable<TIn> previousInChain,
    this.transformation,
  ) : super(initialValue, previousInChain) {
    init(previousInChain);
  }

  @override
  void init(ValueListenable<TIn> previousInChain) {
    internalHandler = () {
      value = transformation(previousInChain.value);
    };
    setupChain();
  }
}

class WhereValueNotifier<T> extends FunctionalValueNotifier<T, T> {
  final bool Function(T) selector;

  WhereValueNotifier(
    T initialValue,
    ValueListenable<T> previousInChain,
    this.selector,
  ) : super(initialValue, previousInChain) {
    init(previousInChain);
  }

  @override
  void init(ValueListenable<T> previousInChain) {
    internalHandler = () {
      if (selector(previousInChain.value)) {
        value = previousInChain.value;
      }
    };
    setupChain();
  }
}

class DebouncedValueNotifier<T> extends FunctionalValueNotifier<T, T> {
  Timer? debounceTimer;
  final Duration debounceDuration;

  DebouncedValueNotifier(
    T initialValue,
    ValueListenable<T> previousInChain,
    this.debounceDuration,
  ) : super(initialValue, previousInChain) {
    init(previousInChain);
  }

  @override
  void init(ValueListenable<T> previousInChain) {
    internalHandler = () {
      debounceTimer?.cancel();
      debounceTimer = //
          Timer(debounceDuration, () => value = previousInChain.value);
    };
    setupChain();
  }
}

typedef CombiningFunction2<TIn1, TIn2, TOut> = TOut Function(TIn1, TIn2);

class CombiningValueNotifier<TIn1, TIn2, TOut> extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final CombiningFunction2<TIn1, TIn2, TOut> combiner;
  late VoidCallback internalHandler;
  bool chainInitialized = false;

  CombiningValueNotifier(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.combiner,
  ) : super(initialValue) {
    internalHandler =
        () => value = combiner(previousInChain1.value, previousInChain2.value);
    init(previousInChain1, previousInChain2);
  }

  void init(ValueListenable<TIn1> previousInChain1,
      ValueListenable<TIn2> previousInChain2) {
    internalHandler =
        () => value = combiner(previousInChain1.value, previousInChain2.value);
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
    chainInitialized = true;
  }

  @override
  void addListener(VoidCallback listener) {
    /// if we already have a listener that means the subscription chain is already
    /// set up so we don't have to do it again.
    if (!chainInitialized) {
      init(previousInChain1, previousInChain2);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
      chainInitialized = false;
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
  bool chainInitialized = false;

  CombiningValueNotifier3(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.previousInChain3,
    this.combiner,
  ) : super(initialValue) {
    init(previousInChain1, previousInChain2, previousInChain3);
  }

  void init(
    ValueListenable<TIn1> previousInChain1,
    ValueListenable<TIn2> previousInChain2,
    ValueListenable<TIn3> previousInChain3,
  ) {
    internalHandler = () => value = combiner(
          previousInChain1.value,
          previousInChain2.value,
          previousInChain3.value,
        );
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
    previousInChain3.addListener(internalHandler);
    chainInitialized = true;
  }

  @override
  void addListener(VoidCallback listener) {
    /// if we already have a listener that means the subscription chain is already
    /// set up so we don't have to do it again.
    if (!chainInitialized) {
      init(previousInChain1, previousInChain2, previousInChain3);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
      previousInChain3.removeListener(internalHandler);
      chainInitialized = false;
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
  bool chainInitialized = false;

  CombiningValueNotifier4(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.previousInChain3,
    this.previousInChain4,
    this.combiner,
  ) : super(initialValue) {
    init(
      previousInChain1,
      previousInChain2,
      previousInChain3,
      previousInChain4,
    );
  }

  void init(
    ValueListenable<TIn1> previousInChain1,
    ValueListenable<TIn2> previousInChain2,
    ValueListenable<TIn3> previousInChain3,
    ValueListenable<TIn4> previousInChain4,
  ) {
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
    chainInitialized = true;
  }

  @override
  void addListener(VoidCallback listener) {
    /// if we already have a listener that means the subscription chain is already
    /// set up so we don't have to do it again.
    if (!chainInitialized) {
      init(previousInChain1, previousInChain2, previousInChain3,
          previousInChain4);
    }
    super.addListener(listener);
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

typedef CombiningFunction5<TIn1, TIn2, TIn3, TIn4, TIn5, TOut> = TOut Function(
    TIn1, TIn2, TIn3, TIn4, TIn5);

class CombiningValueNotifier5<TIn1, TIn2, TIn3, TIn4, TIn5, TOut>
    extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final ValueListenable<TIn3> previousInChain3;
  final ValueListenable<TIn4> previousInChain4;
  final ValueListenable<TIn5> previousInChain5;
  final CombiningFunction5<TIn1, TIn2, TIn3, TIn4, TIn5, TOut> combiner;
  late VoidCallback internalHandler;
  bool chainInitialized = false;

  CombiningValueNotifier5(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.previousInChain3,
    this.previousInChain4,
    this.previousInChain5,
    this.combiner,
  ) : super(initialValue) {
    init(previousInChain1, previousInChain2, previousInChain3, previousInChain4,
        previousInChain5);
  }

  void init(
    ValueListenable<TIn1> previousInChain1,
    ValueListenable<TIn2> previousInChain2,
    ValueListenable<TIn3> previousInChain3,
    ValueListenable<TIn4> previousInChain4,
    ValueListenable<TIn5> previousInChain5,
  ) {
    internalHandler = () => value = combiner(
          previousInChain1.value,
          previousInChain2.value,
          previousInChain3.value,
          previousInChain4.value,
          previousInChain5.value,
        );
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
    previousInChain3.addListener(internalHandler);
    previousInChain4.addListener(internalHandler);
    previousInChain5.addListener(internalHandler);
    chainInitialized = true;
  }

  @override
  void addListener(VoidCallback listener) {
    /// if we already have a listener that means the subscription chain is already
    /// set up so we don't have to do it again.
    if (!chainInitialized) {
      init(previousInChain1, previousInChain2, previousInChain3,
          previousInChain4, previousInChain5);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
      previousInChain3.removeListener(internalHandler);
      previousInChain4.removeListener(internalHandler);
      previousInChain5.removeListener(internalHandler);
      chainInitialized = false;
    }
  }

  @override
  void dispose() {
    previousInChain1.removeListener(internalHandler);
    previousInChain2.removeListener(internalHandler);
    previousInChain3.removeListener(internalHandler);
    previousInChain4.removeListener(internalHandler);
    previousInChain5.removeListener(internalHandler);
    super.dispose();
  }
}

typedef CombiningFunction6<TIn1, TIn2, TIn3, TIn4, TIn5, TIn6, TOut> = TOut
    Function(TIn1, TIn2, TIn3, TIn4, TIn5, TIn6);

class CombiningValueNotifier6<TIn1, TIn2, TIn3, TIn4, TIn5, TIn6, TOut>
    extends ValueNotifier<TOut> {
  final ValueListenable<TIn1> previousInChain1;
  final ValueListenable<TIn2> previousInChain2;
  final ValueListenable<TIn3> previousInChain3;
  final ValueListenable<TIn4> previousInChain4;
  final ValueListenable<TIn5> previousInChain5;
  final ValueListenable<TIn6> previousInChain6;
  final CombiningFunction6<TIn1, TIn2, TIn3, TIn4, TIn5, TIn6, TOut> combiner;
  late VoidCallback internalHandler;
  bool chainInitialized = false;

  CombiningValueNotifier6(
    TOut initialValue,
    this.previousInChain1,
    this.previousInChain2,
    this.previousInChain3,
    this.previousInChain4,
    this.previousInChain5,
    this.previousInChain6,
    this.combiner,
  ) : super(initialValue) {
    init(previousInChain1, previousInChain2, previousInChain3, previousInChain4,
        previousInChain5, previousInChain6);
  }

  void init(
    ValueListenable<TIn1> previousInChain1,
    ValueListenable<TIn2> previousInChain2,
    ValueListenable<TIn3> previousInChain3,
    ValueListenable<TIn4> previousInChain4,
    ValueListenable<TIn5> previousInChain5,
    ValueListenable<TIn6> previousInChain6,
  ) {
    internalHandler = () => value = combiner(
          previousInChain1.value,
          previousInChain2.value,
          previousInChain3.value,
          previousInChain4.value,
          previousInChain5.value,
          previousInChain6.value,
        );
    previousInChain1.addListener(internalHandler);
    previousInChain2.addListener(internalHandler);
    previousInChain3.addListener(internalHandler);
    previousInChain4.addListener(internalHandler);
    previousInChain5.addListener(internalHandler);
    previousInChain6.addListener(internalHandler);
    chainInitialized = true;
  }

  @override
  void addListener(VoidCallback listener) {
    /// if we already have a listener that means the subscription chain is already
    /// set up so we don't have to do it again.
    if (!chainInitialized) {
      init(previousInChain1, previousInChain2, previousInChain3,
          previousInChain4, previousInChain5, previousInChain6);
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      previousInChain1.removeListener(internalHandler);
      previousInChain2.removeListener(internalHandler);
      previousInChain3.removeListener(internalHandler);
      previousInChain4.removeListener(internalHandler);
      previousInChain5.removeListener(internalHandler);
      previousInChain6.removeListener(internalHandler);
      chainInitialized = false;
    }
  }

  @override
  void dispose() {
    previousInChain1.removeListener(internalHandler);
    previousInChain2.removeListener(internalHandler);
    previousInChain3.removeListener(internalHandler);
    previousInChain4.removeListener(internalHandler);
    previousInChain5.removeListener(internalHandler);
    previousInChain6.removeListener(internalHandler);
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
    init(previousInChain);
  }

  @override
  void init(ValueListenable<T> previousInChain) {
    disposeFuncs = mergeWith.map<VoidCallback>((notifier) {
      final notifyHandler = () => value = notifier.value;
      notifier.addListener(notifyHandler);
      return () => notifier.removeListener(notifyHandler);
    }).toList();

    internalHandler = () => value = previousInChain.value;
    setupChain();
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

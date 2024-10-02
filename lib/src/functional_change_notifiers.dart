import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:functional_listener/functional_listener.dart';

abstract class FunctionalChangeNotifier extends ChangeNotifier {
  final Listenable previousInChain;
  late VoidCallback internalHandler;

  @protected
  bool chainInitialized = false;

  FunctionalChangeNotifier(
    this.previousInChain,
  );

  void init(Listenable previousInChain);

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
  void dispose() {
    previousInChain.removeListener(internalHandler);
    super.dispose();
  }
}

extension FunctionaListener2 on Listenable {
  ///
  /// let you work with a `Listenable` as it should be by installing a
  /// [handler] function that is called on any value change of `this` and gets
  /// the new value passed as an argument.
  /// It returns a subscription object that lets you stop the [handler] from
  /// being called by calling [cancel()] on the subscription.
  /// The [handler] get the subscription object passed on every call so that it
  /// is possible to uninstall the [handler] from the [handler] itself.
  ///
  /// example:
  /// ```
  ///
  /// final listenable = ChangeNotifier;
  /// final subscription = listenable.listen((_) => print('Notified'));
  ///
  /// final subscription = listenable.listen((subscription) {
  ///   print('Notified');
  ///   subscription.cancel();
  /// }
  ///
  ListenableSubscription listen(
    void Function(ListenableSubscription) handler,
  ) {
    final subscription = ListenableSubscription(simpleListenble: this);
    subscription.handler = () => handler(subscription);
    addListener(subscription.handler);
    return subscription;
  }

  Listenable debounce(Duration timeOut) {
    return DebouncedChangeNotifier(this, timeOut);
  }
}

class DebouncedChangeNotifier extends FunctionalChangeNotifier {
  Timer? debounceTimer;
  final Duration debounceDuration;

  DebouncedChangeNotifier(
    Listenable previousInChain,
    this.debounceDuration,
  ) : super(previousInChain) {
    init(previousInChain);
  }

  @override
  void init(Listenable previousInChain) {
    internalHandler = () {
      debounceTimer?.cancel();
      debounceTimer = Timer(debounceDuration, notifyListeners);
    };
    setupChain();
  }
}

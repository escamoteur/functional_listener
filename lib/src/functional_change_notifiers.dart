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

// ignore_for_file: unnecessary_this
library functional_listener;

import 'package:flutter/foundation.dart';
import 'package:functional_listener/src/functional_value_notifiers.dart';

/// extension functions on `ValueListenable` that allows you to work with them almost
/// as if it was a synchronous stream. Each extension function returns a new
/// `ValueNotifier` that updates its value when the value of `this` changes
/// You can chain these functions to build complex processing
/// pipelines from a simple `ValueListenable`
/// In the examples we use [listen] to react on value changes. Instead of applying [listen] you
/// could also pass the end of the function chain to a `ValueListenableBuilder`
extension FunctionaListener<T> on ValueListenable<T> {
  ///
  /// let you work with a `ValueListenable` as it should be by installing a
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
  /// final listenable = ValueNotifier<int>(0);
  /// final subscription = listenable.listen((x, _) => print(x));
  ///
  /// final subscription = listenable.listen((x, subscription) {
  ///   print(x);
  ///   if (x == 42){
  ///      subscription.cancel();
  ///   }
  /// }
  ///
  ListenableSubscription listen(
    void Function(T, ListenableSubscription) handler,
  ) {
    final subscription = ListenableSubscription(this);
    subscription.handler = () => handler(this.value, subscription);
    this.addListener(subscription.handler);
    return subscription;
  }

  ///
  /// converts a ValueListenable to another type [T] by returning a new connected
  /// `ValueListenable<T>`
  /// on each value change of `this` the conversion function
  /// [convert] is called to do the type conversion
  ///
  /// example (lets pretend that print wouldn't automatically call toString):
  /// ```
  /// final sourceListenable = ValueNotifier<int>(0);
  /// final subscription = sourceListenable.map<String>( (x)
  ///    => x.toString()).listen( (s,_) => print(x) );
  ///```
  ValueListenable<TResult> map<TResult>(TResult Function(T) convert) {
    return MapValueNotifier<T, TResult>(
      convert(this.value),
      this,
      convert,
    );
  }

  ///
  /// [select] allows you to set a filter on a `ValueListenable` like [where],
  /// and the returned `ValueListenable` only emit a new value when the returned value of [selector] function change.
  /// With this you can react on a specific value change of a property of the ValueListenable.
  ///
  /// example
  /// ```
  /// ValueNotifier<Size> sourceListenable = ValueNotifier<Size>(const Size(10, 10));
  /// int count = 0;
  /// var subscription = sourceListenable.select<double>((x)=> x.height).listen((_, __) => count++);
  ///
  /// sourceListenable.value = const Size(100,10);
  /// sourceListenable.value = const Size(200,200);
  ///```
  /// count will be just 1
  ValueListenable<TResult> select<TResult>(TResult Function(T) selector) {
    return SelectValueNotifier(
      selector(value),
      this,
      selector,
    );
  }

  ///
  /// [where] allows you to set a filter on a `ValueListenable` so that an installed
  /// handler function is only called if the passed
  /// [selector] function returns true. Because the selector function is called on
  /// every new value you can change the filter during runtime.
  ///
  /// ATTENTION: Due to the nature of ValueListeners that they always have to have
  /// a value the filter can't work on the initial value. Therefore it's not
  /// advised to use [where] inside the Widget tree if you use `setState` because that
  /// will recreate the underlying `WhereValueNotifier` again passing through the lates
  /// value of the `this` even if it doesn't fulfill the [selector] condition.
  /// Therefore it's better not to use it directly in the Widget tree but in
  /// your state objects
  ///
  /// example: lets only print even values
  /// ```
  /// final sourceListenable = ValueNotifier<int>(0);
  /// final subscription = sourceListenable.where( (x)=>x.isEven )
  ///    .listen( (s,_) => print(x) );
  ///```
  ValueListenable<T> where(bool Function(T) selector) {
    return WhereValueNotifier(this.value, this, selector);
  }

  ///
  /// If you get too much value changes during a short time period and you don't
  /// want or can handle them all [debounce] can help you.
  /// If you add a [debounce] to your listenable processing pipeline the returned
  /// `ValueListenable` will not emit an updated value before at least
  /// [timpeout] time has passed since the last value change. All value changes
  /// before will be discarded.
  ///
  /// ATTENTION: If you use [debounce] inside the Widget tree in combination with
  /// `setState` it can happen that debounce doesn't have any effect. Better to use it
  /// inside your model objects
  ///
  /// example:
  /// ```
  /// final listenable = ValueNotifier<int>(0);
  ///
  /// listenable
  ///     .debounce(const Duration(milliseconds: 500))
  ///     .listen((x, _) => print(x));
  ///
  /// listenable.value = 42;
  /// await Future.delayed(const Duration(milliseconds: 100));
  /// listenable.value = 43;
  /// await Future.delayed(const Duration(milliseconds: 100));
  /// listenable.value = 44;
  /// await Future.delayed(const Duration(milliseconds: 350));
  /// listenable.value = 45;
  /// await Future.delayed(const Duration(milliseconds: 550));
  /// listenable.value = 46;
  ///
  /// ```
  ///  will print out 45
  ///
  ValueListenable<T> debounce(Duration timeOut) {
    return DebouncedValueNotifier(this.value, this, timeOut);
  }

  /// ValueListenable are inherently synchronous. In most cases this is what you
  /// want. But if for example your ValueListenable gets updated inside a build
  /// method of a widget which would trigger a rebuild because your widgets is
  /// listening to the ValueListenable you get an exception that you called setState
  /// inside a build method.
  /// By using [async] you push the update of the ValueListenable to the next
  /// frame. This way you can update the ValueListenable inside a build method
  /// without getting an exception.
  ValueListenable<T> async() {
    return AsyncValueNotifier(
      this.value,
      this,
    );
  }

  ///
  /// Imagine having two `ValueNotifier` in you model and you want to update
  /// a certain region of the screen with their values every time one of them
  /// get updated.
  /// [combineLatest] combines two `ValueListenable` in that way that it returns
  /// a new `ValueNotifier` that changes its value of [TOut] whenever one of the
  /// input listenables [this] or [combineWith] updates its value. This new value
  /// is built by the [combiner] function that is called on any value change of
  /// the input listenables.
  ///
  /// example:
  /// ```
  ///    class StringIntWrapper {
  ///      final String s;
  ///      final int i;
  ///
  ///      StringIntWrapper(this.s, this.i);
  ///
  ///      @override
  ///      String toString() {
  ///        return '$s:$i';
  ///      }
  ///    }
  ///
  ///    final listenable1 = ValueNotifier<int>(0);
  ///    final listenable2 = ValueNotifier<String>('Start');
  ///
  ///    final destValues = <StringIntWrapper>[];
  ///    final subscription = listenable1
  ///        .combineLatest<String, StringIntWrapper>(
  ///            listenable2, (i, s) => StringIntWrapper(s, i))
  ///        .listen((x, _) {
  ///      destValues.add(x);
  ///    });
  ///
  ///    listenable1.value = 42;
  ///    listenable1.value = 43;
  ///    listenable2.value = 'First';
  ///    listenable1.value = 45;
  ///
  ///    expect(destValues[0].toString(), 'Start:42');
  ///    expect(destValues[1].toString(), 'Start:43');
  ///    expect(destValues[2].toString(), 'First:43');
  ///    expect(destValues[3].toString(), 'First:45');
  ///  ```
  ///
  ValueListenable<TOut> combineLatest<TIn2, TOut>(
    ValueListenable<TIn2> combineWith,
    CombiningFunction2<T, TIn2, TOut> combiner,
  ) {
    return CombiningValueNotifier<T, TIn2, TOut>(
      combiner(this.value, combineWith.value),
      this,
      combineWith,
      combiner,
    );
  }

  ///
  /// Similar to what [combineLatest] does. Only change is you can listen to 3 ValueNotifiers together
  /// usage e.g:
  /// final subscription = listenable1
  //         .combineLatest3<String, String, String>(
  //             listenable2, listenable3, (i, j, s) => "$i:$j:$s")
  //         .listen((x, _) {
  //       print(x);
  //     });
  ValueListenable<TOut> combineLatest3<TIn2, TIn3, TOut>(
      ValueListenable<TIn2> combineWith2,
      ValueListenable<TIn3> combineWith3,
      CombiningFunction3<T, TIn2, TIn3, TOut> combiner) {
    return CombiningValueNotifier3<T, TIn2, TIn3, TOut>(
      combiner(this.value, combineWith2.value, combineWith3.value),
      this,
      combineWith2,
      combineWith3,
      combiner,
    );
  }

  ///
  /// Similar to what [combineLatest] does. Only change is you can listen to 4 ValueNotifiers together
  /// usage e.g:
  /// final subscription = listenable1
  //         .combineLatest4<String, String, String, String>(
  //             listenable2, listenable3, listenable4, (i, j, k, s) => "$i:$j:$k:$s")
  //         .listen((x, _) {
  //       print(x);
  //     });
  ValueListenable<TOut> combineLatest4<TIn2, TIn3, TIn4, TOut>(
      ValueListenable<TIn2> combineWith2,
      ValueListenable<TIn3> combineWith3,
      ValueListenable<TIn4> combineWith4,
      CombiningFunction4<T, TIn2, TIn3, TIn4, TOut> combiner) {
    return CombiningValueNotifier4<T, TIn2, TIn3, TIn4, TOut>(
      combiner(this.value, combineWith2.value, combineWith3.value,
          combineWith4.value),
      this,
      combineWith2,
      combineWith3,
      combineWith4,
      combiner,
    );
  }

  ///
  /// Similar to what [combineLatest] does. Only change is you can listen to 5 ValueNotifiers together
  /// usage e.g:
  /// final subscription = listenable1
  //         .combineLatest5<String, String, String, String, String>(
  //             listenable2,
  //             listenable3,
  //             listenable4,
  //             listenable5,
  //             (i, j, k, l, s) => "$i:$j:$k:$l:$s")
  //         .listen((x, _) {
  //       print(x);
  //     });
  ValueListenable<TOut> combineLatest5<TIn2, TIn3, TIn4, TIn5, TOut>(
      ValueListenable<TIn2> combineWith2,
      ValueListenable<TIn3> combineWith3,
      ValueListenable<TIn4> combineWith4,
      ValueListenable<TIn5> combineWith5,
      CombiningFunction5<T, TIn2, TIn3, TIn4, TIn5, TOut> combiner) {
    return CombiningValueNotifier5<T, TIn2, TIn3, TIn4, TIn5, TOut>(
      combiner(this.value, combineWith2.value, combineWith3.value,
          combineWith4.value, combineWith5.value),
      this,
      combineWith2,
      combineWith3,
      combineWith4,
      combineWith5,
      combiner,
    );
  }

  ///
  /// Similar to what [combineLatest] does. Only change is you can listen to 6 ValueNotifiers together
  /// usage e.g:
  /// final subscription = listenable1
  ///         .combineLatest6<String, String, String, String, String, String>(
  ///             listenable2,
  ///             listenable3,
  ///             listenable4,
  ///             listenable5,
  ///             listenable6,
  ///             (i, j, k, l, m, s) => "$i:$j:$k:$l:$m:$s")
  ///         .listen((x, _) {
  ///       print(x);
  ///     });
  ValueListenable<TOut> combineLatest6<TIn2, TIn3, TIn4, TIn5, TIn6, TOut>(
      ValueListenable<TIn2> combineWith2,
      ValueListenable<TIn3> combineWith3,
      ValueListenable<TIn4> combineWith4,
      ValueListenable<TIn5> combineWith5,
      ValueListenable<TIn6> combineWith6,
      CombiningFunction6<T, TIn2, TIn3, TIn4, TIn5, TIn6, TOut> combiner) {
    return CombiningValueNotifier6<T, TIn2, TIn3, TIn4, TIn5, TIn6, TOut>(
      combiner(this.value, combineWith2.value, combineWith3.value,
          combineWith4.value, combineWith5.value, combineWith6.value),
      this,
      combineWith2,
      combineWith3,
      combineWith4,
      combineWith5,
      combineWith6,
      combiner,
    );
  }

  /// Merges value changes of [this] together with value changes of a List of
  /// `ValueListenables` so that when ever any of them changes the result of
  /// [mergeWith] will change too.
  ///
  /// ```
  ///     final listenable1 = ValueNotifier<int>(0);
  ///     final listenable2 = ValueNotifier<int>(0);
  ///     final listenable3 = ValueNotifier<int>(0);
  ///     final listenable4 = ValueNotifier<int>(0);
  ///
  ///     listenable1.mergeWith([listenable2, listenable3, listenable4])
  ///          .listen((x, _) => print(x));
  ///
  ///     listenable2.value = 42;
  ///     listenable1.value = 43;
  ///     listenable4.value = 44;
  ///     listenable3.value = 45;
  ///     listenable1.value = 46;
  ///     ```
  ///   Will print 42,43,44,45,46
  ///
  ValueListenable<T> mergeWith(
    List<ValueListenable<T>> mergeWith,
  ) =>
      MergingValueNotifiers<T>(this, mergeWith, this.value);
}

/// Object that is returned by [listen] that allows you to stop the calling of the
/// handler that you passed to it.
class ListenableSubscription {
  final ValueListenable endOfPipe;
  late VoidCallback handler;
  bool canceled = false;

  ListenableSubscription(this.endOfPipe);

  /// Removes the handler that you installed with [listen]
  /// It's save to call cancel on an already canceled subscription
  void cancel() {
    if (!canceled) {
      endOfPipe.removeListener(handler);
      canceled = true;
    }
  }
}

enum CustomNotifierMode { normal, manual, always }

/// Sometimes you want a ValueNotifier where you can control when its
/// listeners are notified. With the `CustomValueNotifier` you can do this:
/// If you pass [CustomNotifierMode.always] for the [mode] parameter,
/// `notifierListeners` will be called everytime you assign a value to the
/// [value] property independent of if the value is different from the
/// previous one.
/// If you pass [CustomNotifierMode.manual] for the [mode] parameter,
/// `notifierListeners` will not be called when you assign a value to the
/// [value] property. You have to call it manually to notify the Listeners.
/// Aditionally it has a [listenerCount] property that tells you how many
/// listeners are currently listening to the notifier.
class CustomValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  T _value;
  final CustomNotifierMode mode;
  int listenerCount = 0;

  /// If true, the listeners will be notified asynchronously, which can be helpful
  /// if you encounter problems that you trigger rebuilds during the build phase.
  final bool asyncNotification;

  @override
  T get value => _value;

  set value(T val) {
    if (mode == CustomNotifierMode.manual) {
      _value = val;
      return;
    }
    if (val != _value || mode == CustomNotifierMode.always) {
      _value = val;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (asyncNotification) {
      Future(() => super.notifyListeners);
    } else {
      super.notifyListeners();
    }
  }

  CustomValueNotifier(
    T initialValue, {
    this.mode = CustomNotifierMode.normal,
    this.asyncNotification = false,
  }) : _value = initialValue;
  @override
  void addListener(void Function() listener) {
    super.addListener(listener);
    listenerCount++;
  }

  @override
  void removeListener(void Function() listener) {
    super.removeListener(listener);
    listenerCount--;
  }

  @override
  void dispose() {
    super.dispose();
    listenerCount = 0;
  }
}

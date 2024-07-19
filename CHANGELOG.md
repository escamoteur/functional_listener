## [3.0.0] - 19.07.2024
* added optional error handler for CustomValueNotifier in case one of the listeners throws an Exception
* added` `listen() extension method for normal Listenable
## [2.3.1] - 28.02.2023

* stupid bug fix
## [2.3.0] - 28.02.2023
* added `async()` extension method

```dart

  /// ValueListenable are inherently synchronous. In most cases this is what you
  /// want. But if for example your ValueListenable gets updated inside a build
  /// method of a widget which would trigger a rebuild because your widgets is
  /// listening to the ValueListenable you get an exception that you called setState
  /// inside a build method.
  /// By using [async] you push the update of the ValueListenable to the next
  /// frame. This way you can update the ValueListenable inside a build method
  /// without getting an exception.
  ValueListenable<T> async();
```
* `CustomValueNotifier` got a new property `asyncNotification` which if set to true postpones the notifications of listeners to the end of the frame which can be helpful if you run into Exceptions about 'calling setState inside a build function' e.g. if you monitor the `CustomValueNotifier` with the get_it_mixin and you update it inside the build function. Default is false.

## [2.2.0] - 24.02.2023

* added listenerCount to CustomValueNotfier

# [2.1.0] - 29.01.2022

* merged several PRs with bugfixes
* adds the `select()` method see the readme
* adds more `combineLates()` variants up to 6 input Listenables
## [2.0.2] - 07.05.2021

* Bugfix: If you resubscribed to one of the Listenables that are returned from the extension functions in this package and then resubscribed it did not rebuild the subcription to it's previous in chain.

## [2.0.1] - 05.05.2021

* Added public `notifyListeners` to `CustomValueNotfier` 

## [2.0.0] - 15.02.2021

* Added `CustomValueNotfier` 
## [1.1.1] - 30.11.2020

* Fixes in documentation and tests 
## [1.1.0] - 05.10.2020

* Added mergeWith() function

## [1.0.1] - 03.08.2020

* Added package description

## [1.0.0] - 03.08.2020

* Added Example and some bug fixes

## [0.8.0] - 30.07.2020

* Initial release

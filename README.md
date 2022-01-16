# functional_listener

Extension functions on `ValueListenable` that allows you to work with them almost as if it was a synchronous stream. Each extension function returns a new `ValueNotifier` that updates its value when the value of `this` changes. You can chain these functions to build complex processing pipelines from a simple `ValueListenable`.

Here are some examples how to use it:

## listen()

Lets you work with a `ValueListenable` as it should be by installing a handler function that is called on any value change of `this` and gets the new value passed as an argument. 

If we want to print every new value of a `ValueListenable<int>` we can do:

```Dart
final listenable = ValueNotifier<int>(0);
final subscription = listenable.listen((x, _) => print(x));
```
The returned `subscription` can be used to deactivate the passed handler function. As you might need to uninstall the handler function from inside the handler 
you get the subscription object passed to the handler function as second parameter like:

```Dart
listenable.listen((x, subscription) {
  print(x);
  if (x == 42){
     subscription.cancel();
  }
})
```

## map()
Lets you convert the value of one `ValueListenable` to anything you want.
Imagine we have a `ValueNotifier<String>` in an Model object that we can't change but we need it's value all UPPER CASE in our UI:

```Dart
  ValueNotifier<String> source;  //this is the one from the model object

  final upperCaseSource = source.map( (s)=>s.toUpperCase() );
``` 

or you can change the type:

```Dart
  ValueNotifier<int> intNotifier;  

  final stringNotifier = intNotifier.map<String>( (s)=>s.toString() );
``` 

## where()

Lets you filter the values that a ValueListenable can have:


```Dart
  ValueNotifier<int> intNotifier;  
  bool onlyEven = false; // depending on this variable we want only even values or all

  final filteredNotifier = intNotifier.where( (i)=> onlyEven ? i.isEven : i );
``` 


## select()

Lets you ignore value changes on a ValueListenable.

This is usefully when you have a complex state model, and only want to react when a specific property change.
```Dart
  ValueNotifier<User> notifier = ValueNotifier(User(age: 18, property2: "John"));

  final birthdayNotifier = notifier.select<int>((model)=> model.age); //selectedNotifier will ignore changes that does not affect age
``` 
The selector function that you pass to `select` is called on every new value, but only propagate it when the returned value distinct.

### chaining functions
As all the extension function (with the exception of `listen`) return a new `ValueNotifier` we can chain these extension functions as we need them like: 


```Dart
  ValueNotifier<int> intNotifier;  

  intNotifier.where((x)=>x.isEven).map<String>( (s)=>s.toString() ).listen(print);
``` 

## debounce()
If you don't want or can't handle too rapid value changes `debounce` is your friend. It only propagates values if there is a pause after a value changes. Most typical example is you have a search function that polls a REST API and in every change of the search term you execute a http request. To avoid overloading your REST server you probably want to avoid that a new request is made on every keypress. I makes much more sense to wait till the user stops modifying the search term for a moment.


```Dart
  ValueNotifier<String> searchTerm;  //this is the one from the model object

  searchTerm.debounce(const Duration(milliseconds: 500)).listen((s)  => callRestApi(s) );

  // We ignore for this example that calling a REST API probably involves some async magic
``` 

## combineLatest()
Combines two source `ValueListenables` to one that gets updated with the combined source values when any of the sources values changed.
This comes in handy if you want to use one `ValueListenableBuilder` with two `ValueNotifiers`.

```Dart
class StringIntWrapper {
  final String s;
  final int i;

  StringIntWrapper(this.s, this.i);

  @override
  String toString() {
    return '$s:$i';
  }
}


ValueNotifier<int> intNotifier;  
ValueNotifier<String> stringNotifier;  

intNotifier.combineLastest<String,StringIntWrapper>(stringNotifier, (i,s)
   => StringIntWrapper(s,i)).listen(print);
```

## mergeWith
Merges value changes of one `ValueListenable` together with value changes of a List of
`ValueListenables` so that when ever any of them changes the result of
`mergeWith()` will change too.

```dart
final listenable1 = ValueNotifier<int>(0);
final listenable2 = ValueNotifier<int>(0);
final listenable3 = ValueNotifier<int>(0);
final listenable4 = ValueNotifier<int>(0);

listenable1.mergeWith([listenable2, listenable3, listenable4]).listen(
    (x, _) => print(x));

listenable2.value = 42;
listenable1.value = 43;
listenable4.value = 44;
listenable3.value = 45;
listenable1.value = 46;
```
Will print 42,43,44,45,46


For details on the functions check the source documentation, the tests and the example.

## CustomValueNotifier

```Dart
/// If you pass [CustomNotifierMode.always] for the [mode] parameter,
/// `notifierListeners` will be called everytime you assign a value to the
/// [value] property independent of if the value is different from the
/// previous one.
/// If you pass [CustomNotifierMode.manual] for the [mode] parameter,
/// `notifierListeners` will not be called when you assign a value to the
/// [value] property. You have to call it manually to notifiy the Listeners.
class CustomValueNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  T _value;
  final mode;
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

  CustomValueNotifier(
    T initialValue, {
    this.mode = CustomNotifierMode.normal,
  }) : _value = initialValue;
}
```

If you miss a function, open an issue on GitHub or even better make an PR :-)
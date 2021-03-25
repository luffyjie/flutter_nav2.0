/*

ModelBinding<T>: a simple class for binding a Flutter app to a immutable
model of type T.

This is a complete application. The app shows the state of an instance of
MyModel in a button's label, and replaces its MyModel instance when the
button is pressed.

ModelBinding is an inherited widget that must be created in a context above
the widgets that will depend on it. A ModelBinding is created like this:

ModelBinding<MyModel>(
  initialState: MyModel(),
  child: child,
)

ModelBinding provides a static method 'of<T>(context)' that can be used
by any descendant to retrieve the current model instance, and a similar
static 'update<T>(context, T newModel)' method for replacing the
current model. Both methods implicitly create a dependency on the model:
when the model changes the corresponding context will be rebuilt.

In this example the model is retrieved and updated like this:

RaisedButton(
  onPressed: () {
    final MyModel model = ModelBinding.of<MyModel>(context);
    ModelBinding.update<MyModel>(context, MyModel(value: model.value + 1));
  },
  child: Text('Hello World ${ModelBinding.of<MyModel>(context).value}'),
)

To use ModelBinding in your own app define an immutable model class like
MyModel that contains the application's state. Add the three ModelBinding
classes below (_ModelBindingScope, ModelBinding, _ModelBindingState) to a file
and import that where it's needed.

*/

import 'package:flutter/material.dart';

class MyModel {
  const MyModel({this.value = 0});

  final int value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final MyModel otherModel = other;
    return otherModel.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({Key key, this.modelBindingState, Widget child})
      : super(key: key, child: child);

  final _ModelBindingState<T> modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

class ModelBinding<T> extends StatefulWidget {
  ModelBinding({
    Key key,
    @required this.initialModel,
    this.child,
  })  : assert(initialModel != null),
        super(key: key);

  final T initialModel;
  final Widget child;

  _ModelBindingState<T> createState() => _ModelBindingState<T>();

  static Type _typeOf<T>() =>
      T; // https://github.com/dart-lang/sdk/issues/33297

  static T of<T>(BuildContext context) {
    final _ModelBindingScope<T> scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    return scope.modelBindingState.currentModel;
  }

  static void update<T>(BuildContext context, T newModel) {
    final _ModelBindingScope<dynamic> scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>();
    scope.modelBindingState.updateModel(newModel);
  }
}

class _ModelBindingState<T> extends State<ModelBinding<T>> {
  T currentModel;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  void updateModel(T newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope<T>(
      modelBindingState: this,
      child: widget.child,
    );
  }
}

class ViewController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        final MyModel model = ModelBinding.of<MyModel>(context);
        ModelBinding.update<MyModel>(context, MyModel(value: model.value + 1));
      },
      child: Text('Hello World ${ModelBinding.of<MyModel>(context).value}'),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ModelBinding<MyModel>(
        initialModel: const MyModel(),
        child: Scaffold(
          body: Center(
            child: ViewController(),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(App());
}

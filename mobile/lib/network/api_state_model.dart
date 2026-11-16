import 'package:eventpass/models/states.dart';

/// The single state type every API notifier exposes.
///  - [states]  : what the UI should render (LOADING / DATA / ERROR …)
///  - [message] : text to show (error, success or loading message)
///  - [data]    : the parsed response object on DATA, otherwise usually null
class ApiStatesModel {
  ApiStatesModel(this.states, this.message, this.data);

  States states;
  String message;
  dynamic data;

  @override
  String toString() => 'ApiStatesModel(${states.name}, "$message", ${data.runtimeType})';
}

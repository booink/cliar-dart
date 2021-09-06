import './arg.dart';
import './../cliar.dart';

class ArgsParser {
  late final Cliar _target;
  late final List<Arg> _specs;
  ArgsParser(this._target, this._specs);

  parse(List<String> arguments) {
    for (Arg arg in _specs) {
      if (arg is Flag) {
        arg.setValueFromArguments(_target, arguments);
      }
    }
    for (Arg arg in _specs) {
      if (arg is Option) {
        arg.setValueFromArguments(_target, arguments);
      }
    }
    for (Arg arg in _specs) {
      if (arg is Positional) {
        arg.setValueFromArguments(_target, arguments);
      }
    }
  }
}
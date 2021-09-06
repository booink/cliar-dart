/// Support for doing something awesome.
///
/// More dartdocs go here.
library cliar;

import 'dart:io';

import './src/arg.dart';
import './src/usage_builder.dart';
import './src/args_parser.dart';
import 'dart:mirrors';

class CliarArgumentsException {}

abstract class Cliar {
  final List<Arg> _specs = [];

  Cliar(List<String> arguments, { bool canPrintUsage = true, bool canExit = true }) {
    List<String> _arguments = [];
    for (String a in arguments) {
      // Unsupported operation: Cannot remove from a fixed-length list になるので arguments 詰め替え
      _arguments.add(a);
    }
    build();
    try {
      parse(_arguments);
    } on CliarArgumentsException {
      if (canPrintUsage) {
        printUsage();
      }
      if (canExit) {
        exit(0);
      }
      if (!canPrintUsage && !canExit) {
        throw CliarArgumentsException();
      }
    }
  }

  build() {
    InstanceMirror im = reflect(this);
    ClassMirror classMirror = im.type;

    classMirror.declarations.forEach((key, value) {
      bool nullable = false;
      try {
        var defaultValue = im.getField(key).reflectee;
        nullable = defaultValue == null;
      } catch (e) {
        // NO-OP
      }
      String originalName = MirrorSystem.getName(key);
      if (value is VariableMirror) {
        Type type = value.type.reflectedType;
        if (value.metadata.isNotEmpty) {
          var a = value.metadata.first.reflectee;
          if (a is arg) {
            Arg _arg = a.toArg(originalName, type, nullable);
            if (!_arg.validate()) {
              // 例外
            }
            _specs.add(_arg);
          }
        }
      }
    });
  }

  parse(List<String> _arguments) {
    ArgsParser(this, _specs).parse(_arguments);
  }

  printUsage() {
    print(UsageBuilder(_specs).output());
  }
}

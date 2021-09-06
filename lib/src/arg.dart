import 'package:cliar/cliar.dart';
import 'package:cliar/src/usage_text.dart';
import 'package:recase/recase.dart';
import 'dart:mirrors';
import './arg_validator.dart';

// ignore_for_file: camel_case_types
abstract class arg {
  final String? name;
  final String? description;
  const arg({this.name, this.description});

  void output();
  dynamic toArg(String originalName, Type type, bool nullable);

  String _fixName(String originalName) {
    String _name;
    if (name == null) {
      _name = originalName;
    } else {
      _name = name!;
    }
    ReCase rc = ReCase(_name);
    return rc.paramCase;
  }

  String _fixDescription() {
    return description ?? '';
  }
}

abstract class Arg {
  late final String _originalName;
  String get originalName => _originalName;

  late final String _name;
  get name => _name;
  late final String _description;
  get description => _description;

  late final Type _type;
  get type => _type;
  late final bool _nullable;

  Arg(this._originalName, this._name, this._type, this._description, this._nullable);

  UsageText get usageText;

  bool validate();

  setValueFromArguments(Cliar obj, List<String> arguments);

  void debug() {
    List<String> outputs = [];
    InstanceMirror im = reflect(this);
    ClassMirror classMirror = im.type;
    classMirror.instanceMembers.forEach((key, value) {
      String name = MirrorSystem.getName(key);
      if (value is MethodMirror && value.isGetter && name.startsWith("_") && name != "_arg") {
        outputs.add("${name.substring(1)}: ${im.getField(key).reflectee}");
      }
    });
    outputs.add("enum?: $isEnumType");
    outputs.add("list?: $isListType");
    outputs.add("required?: $required");
    print("$runtimeType: ${outputs.join(", ")}");
  }

  bool isValid() {
    return ArgValidator(this).isValid();
  }

  bool get isEnumType {
    return reflectClass(_type).isEnum;
  }

  bool get required {
    return !_nullable;
  }

  bool get isListType {
    return _type.toString().startsWith("List<");
  }

  bool get isBoolType {
    return _type.toString() == "bool";
  }

  bool get isIntType {
    return _type.toString() == "int";
  }

  dynamic enumFromString(String value, Type t) {
    return (reflectType(t) as ClassMirror).getField(#values).reflectee.firstWhere((e) => e.toString().split('.')[1].toLowerCase() == value.toLowerCase());
  }
}

class Positional extends Arg {
  Positional(_originalName, _name, _type, _description, _nullable) : super(_originalName, _name, _type, _description, _nullable);

  @override
  PositionalUsageText get usageText => PositionalUsageText(_name, _description, required, isListType);

  @override
  bool validate() {
    return true;
  }

  @override
  setValueFromArguments(Cliar obj, List<String> arguments) {
    InstanceMirror target = reflect(obj);
    Symbol sym = Symbol(originalName);
    if (isListType) {
      List<String> values = arguments.take(arguments.length).toList();
      if (required) {
        if (values.isEmpty) {
          throw CliarArgumentsException();
        } else {
          target.setField(sym, values);
        }
      } else {
        List<String>? nullableValues = values.isEmpty ? null : values;
        target.setField(sym, nullableValues);
      }
      arguments.clear();
    } else if (isBoolType) {
      if (arguments.isNotEmpty) {
          target.setField(sym, _isTruthyString(arguments.removeAt(0)));
      } else if (required) {
        throw CliarArgumentsException();
      }
    } else if (isIntType) {
      if (arguments.isNotEmpty) {
        target.setField(sym, int.parse(arguments.removeAt(0)));
      } else if (required) {
        throw CliarArgumentsException();
      }
    } else if (isEnumType) {
      if (arguments.isNotEmpty) {
        target.setField(sym, enumFromString(arguments.removeAt(0), type));
      } else if (required) {
        throw CliarArgumentsException();
      }
    } else {
      if (arguments.isNotEmpty) {
        target.setField(sym, arguments.removeAt(0));
      } else if (required) {
        throw CliarArgumentsException();
      }
    }
  }

  bool _isTruthyString(String value) {
    if (["true", "yes", "1"].contains(value.toLowerCase())) {
      return true;
    }
    return false;
  }
}

class positional extends arg {
  const positional({name, description}) : super(name: name, description: description);

  @override
  void output() {
    print("positional: name: $name, description: $description");
  }

  @override
  Positional toArg(String originalName, Type type, bool nullable) {
    return Positional(originalName, _fixName(originalName), type, _fixDescription(), nullable);
  }
}

class HyphenKeyword {
  late String? _short;
  late String? _long;
  String? get shortName => _short;
  String? get shortOption => "-$shortName";
  String? get longName => _long;
  String? get longOption {
    if (_long != null) {
      ReCase rc = ReCase(longName!);
      return "--${rc.paramCase}";
    }
    return null;
  }
}

class Option extends Arg with HyphenKeyword {
  late final String? _short;
  late final String? _long;
  Option(_originalName, _name, _type, _description, _nullable, this._short, this._long) : super(_originalName, _name, _type, _description, _nullable);

  List<dynamic> valuesForListType = [];

  @override
  OptionUsageText get usageText => OptionUsageText(_name, _description, shortOption, longOption, required);

  @override
  bool validate() {
    if (isBoolType) {
      return false;
    }
    return true;
  }

  @override
  setValueFromArguments(Cliar obj, List<String> arguments) {
    List<int> indices = [];
    arguments.asMap().forEach((i, argument) {
      if (argument == longOption || argument == shortOption) {
        indices.add(i);
      }
    });
    for (int index in indices) {
      _setValueFromArgumentsWithIndex(obj, arguments, index);
    }
  }

  _setValueFromArgumentsWithIndex(Cliar obj, List<String> arguments, int index) {
    InstanceMirror target = reflect(obj);
    if (isListType) {
      arguments.removeAt(index);
      String value = arguments.removeAt(index);
      valuesForListType.add(value);
      target.setField(Symbol(originalName), valuesForListType);
    } else if (isIntType) {
      arguments.removeAt(index);
      String value = arguments.removeAt(index);
      target.setField(Symbol(originalName), int.parse(value));
    } else if (isEnumType) {
      arguments.removeAt(index);
      String value = arguments.removeAt(index);
      target.setField(Symbol(originalName), enumFromString(value, type));
    } else {
      arguments.removeAt(index);
      String value = arguments.removeAt(index);
      target.setField(Symbol(originalName), value);
    }
  }
}

class option extends arg {
  final String? short;
  final String? long;
  const option({name, this.short, this.long, description}) : super(name: name, description: description);

  @override
  void output() {
    print("option: name: $name, short: $short, long: $long, description: $description");
  }

  @override
  Option toArg(String originalName, Type type, bool nullable) {
    String? _short = short;
    String? _long = long;
    if (short == null && long == null) {
      // どちらの指定もなかったら、勝手にどちらも設定する
      _short = originalName.substring(0, 1);
      _long = originalName;
    }
    return Option(originalName, _fixName(originalName), type, _fixDescription(), nullable, _short, _long);
  }
}

class Flag extends Arg with HyphenKeyword {
  late final String? _short;
  late final String? _long;
  Flag(_originalName, _name, _type, _description, _nullable, this._short, this._long) : super(_originalName, _name, _type, _description, _nullable);

  int counterForIntType = 0;

  @override
  FlagUsageText get usageText => FlagUsageText(_name, _description, shortOption, longOption);

  @override
  bool validate() {
    if (isBoolType || isIntType) {
      return true;
    }
    return false;
  }

  @override
  setValueFromArguments(Cliar obj, List<String> arguments) {
    List<int> indices = [];
    arguments.asMap().forEach((i, argument) {
      if (argument == longOption || argument == shortOption) {
        indices.add(i);
      }
    });
    for (int index in indices.reversed) {
      _setValueFromArgumentsWithIndex(obj, arguments, index);
    }
  }

  _setValueFromArgumentsWithIndex(Cliar obj, List<String> arguments, int index) {
    InstanceMirror target = reflect(obj);
    if (isBoolType) {
      target.setField(Symbol(originalName), true);
      arguments.removeAt(index);
    } else if (isIntType) {
      counterForIntType += 1;
      target.setField(Symbol(originalName), counterForIntType);
      arguments.removeAt(index);
    }
  }
}

class flag extends arg {
  final String? short;
  final String? long;
  const flag({name, this.short, this.long, description}) : super(name: name, description: description);

  @override
  void output() {
    print("flag: name: $name, short: $short, long: $long, description: $description");
  }

  @override
  Flag toArg(String originalName, Type type, bool nullable) {
    String? _short = short;
    String? _long = long;
    if (short == null && long == null) {
      // どちらの指定もなかったら、勝手にどちらも設定する
      _short = originalName.substring(0, 1);
      _long = originalName;
    }
    return Flag(originalName, _fixName(originalName), type, _fixDescription(), nullable, _short, _long);
  }
}

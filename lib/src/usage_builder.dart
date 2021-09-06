import './arg.dart';
import './usage_text.dart';
import 'dart:math';

class UsageBuilder {
  final List<PositionalUsageText> _requirePositionalArgs = [];
  final List<PositionalUsageText> _positionalArgs = [];
  final List<OptionUsageText> _requireOptionArgs = [];
  final List<OptionUsageText> _optionArgs = [];
  final List<FlagUsageText> _flagArgs = [];

  List<String> shortOptions = [];
  List<String> longOptions = [];
  List<String> names = [];

  int get shortOptionWidth {
    return shortOptions.map((e) => e.length).reduce(max);
  }

  int get longOptionWidth {
    return longOptions.map((e) => e.length).reduce(max);
  }

  int get nameWidth {
    return names.map((e) => e.length).reduce(max);
  }

  late final List<Arg> _specs;

  UsageBuilder(this._specs) {
    for (Arg arg in _specs) {
      _addArg(arg.usageText);
    }
  }

  void _addArg(UsageText arg) {
    if (arg is PositionalUsageText) {
      if (arg.required) {
        _requirePositionalArgs.add(arg);
      } else {
        _positionalArgs.add(arg);
      }
    } else if (arg is OptionUsageText) {
      shortOptions.add(arg.shortOption ?? "");
      longOptions.add(arg.longOption ?? "");
      names.add(arg.name);
      if (arg.required) {
        _requireOptionArgs.add(arg);
      } else {
        _optionArgs.add(arg);
      }
    } else if (arg is FlagUsageText) {
      shortOptions.add(arg.shortOption ?? "");
      longOptions.add(arg.longOption ?? "");
      _flagArgs.add(arg);
    }
  }

  String output() {
    String command = "cmd-name";
    String text = "";
    if (_requirePositionalArgs.isNotEmpty || _positionalArgs.isNotEmpty) {
      text += "\nARGS:\n";
      for (PositionalUsageText arg in _requirePositionalArgs) {
        command += " <${arg.name}>";
        text += "  ${arg.usageText()}\n";
      }
      if (_positionalArgs.isNotEmpty) {
        command += " [ARGS]";
        for (PositionalUsageText arg in _positionalArgs) {
          text += "  ${arg.usageText()}\n";
        }
      }
    }

    if (_requireOptionArgs.isNotEmpty || _optionArgs.isNotEmpty) {
      text += "\nOPTIONS:\n";
      for (OptionUsageText arg in _requireOptionArgs) {
        command += " ${arg.argumentKey} <${arg.name}>";
        text += "  ${arg.usageTextWithColumnWidths(shortOptionWidth, longOptionWidth, nameWidth)}\n";
      }
      if (_optionArgs.isNotEmpty) {
        command += " [OPTIONS]";
        for (OptionUsageText arg in _optionArgs) {
          text += "  ${arg.usageTextWithColumnWidths(shortOptionWidth, longOptionWidth, nameWidth)}\n";
        }
      }
    }

    if (_flagArgs.isNotEmpty) {
      command += " [FLAGS]";
      text += "\nFLAGS:\n";
      for (FlagUsageText arg in _flagArgs) {
        text += "  ${arg.usageTextWithColumnWidths(shortOptionWidth, longOptionWidth, nameWidth)}\n";
      }
    }

    return "$command\n$text";
  }
}
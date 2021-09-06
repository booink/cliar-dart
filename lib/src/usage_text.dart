abstract class UsageText {
  final String _name;
  final String _description;

  String get name => _name;

  UsageText(this._name, this._description);
}

class PositionalUsageText extends UsageText {
  final bool _required;
  final bool _isListType;

  bool get required => _required;

  PositionalUsageText(_name, _description, this._required, this._isListType) : super(_name, _description);

  String usageText() {
    String name = _name;
    if (!_required) {
      name = "[$name]";
    }
    if (_isListType) {
      name = "$name ...";
    }
    return "$name $_description";
  }
}

abstract class HyphenKeywordUsageText extends UsageText {
  final String? _shortOption;
  final String? _longOption;

  String? get shortOption => _shortOption;
  String? get longOption => _longOption;

  String get argumentKey {
    if (_shortOption != null) {
      return _shortOption!;
    } else {
      return _longOption!;
    }
  }

  HyphenKeywordUsageText(_name, _description, this._shortOption, this._longOption) : super(_name, _description);

  String _usageTextWithColumnWidths(int shortOptionWidth, int longOptionWidth) {
    String shortText = _shortOption ?? "";
    String longText = _longOption ?? "";
    String text = "  ";
    text += shortText.padLeft(shortOptionWidth);
    text += " ";
    text += longText.padRight(longOptionWidth);
    return text;
  }
}

class OptionUsageText extends HyphenKeywordUsageText {
  final bool _required;

  bool get required => _required;

  OptionUsageText(_name, _description, _shortOption, _longOption, this._required) : super(_name, _description, _shortOption, _longOption);

  String usageTextWithColumnWidths(int shortOptionWidth, int longOptionWidth, int nameWidth) {
    String _name = "<$name>";
    int pad = 2; // <name> の <> の文字数
    return "${_usageTextWithColumnWidths(shortOptionWidth, longOptionWidth)} ${_name.padRight(nameWidth + pad)} $_description";
  }
}

class FlagUsageText extends HyphenKeywordUsageText {
  FlagUsageText(_name, _description, _shortOption, _longOption) : super(_name, _description, _shortOption, _longOption);

  String usageTextWithColumnWidths(int shortOptionWidth, int longOptionWidth, int nameWidth) {
    return "${_usageTextWithColumnWidths(shortOptionWidth, longOptionWidth)} ${"".padRight(nameWidth + 2)} $_description";
  }
}

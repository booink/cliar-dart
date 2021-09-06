import 'package:cliar/cliar.dart';
import 'package:cliar/src/arg.dart';

enum Format {
  csv,
  json,
}

class CsvReaderExample extends Cliar {
  // @positional の型を非Nullableにすると必須の引数になります
  @positional(description: 'CSVファイル')
  late String fileName;

  // @positional の型をNullableにすると引数の省略が可能です
  @positional(name: 'files', description: '追加のCSVファイル')
  List<String>? optionFileNames;

  // @option の型を非Nullableにすると必須キーワードになります
  @option(short: 'f', long: 'format', description: '入出力する形式を指定します')
  late Format format;

  // @option の型をNullableにするとキーワードの省略が可能です
  @option(short: 'o', long: 'outputFileName', description: '出力するファイル名を指定します')
  String? output;

  // @option にデフォルト値が指定されている場合は非Nullableでもキーワードの省略が可能です
  @option(short: 'l', long: 'limit', description: '出力するレコード数を指定します')
  int limit = 10;

  // @flag には bool 型が指定できます
  @flag(short: 'h', long: 'hasHeader', description: 'ヘッダー行の有無を指定します')
  bool hasHeader = false;

  // @flag を int型にするとキーワードを指定した回数が値に設定されます
  @flag(short: 'v', description: 'verbose')
  int verbose = 0;

  CsvReaderExample(List<String> arguments, { canPrintUsage = false, canExit = false }) : super(arguments, canPrintUsage: canPrintUsage, canExit: canExit);
}
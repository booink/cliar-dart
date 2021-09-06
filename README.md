# Cliar

Cliar (クリアー) は、コマンドラインオプションを dart のクラスを元に定義できるようにするパッケージです。

## Install

pubspec.yamlのdependenciesに cliar を記述します。

```yaml
dependencies:
  cliar: ^0.1.0
```

## Usage

コマンドオプションを設定するクラスを定義します。
必ずCliarクラスを継承してください。

```dart
import 'package:cliar/cliar.dart';
import 'package:cliar/src/arg.dart';

class CsvReaderExample extends Cliar {
  // @positional の型を非Nullableにすると必須の引数になります
  @positional(description: 'CSVファイル')
  late String fileName;

  // @positional の型をNullableにすると引数の省略が可能です
  @positional(name: 'files', description: '追加のCSVファイル')
  List<String>? optionFileNames;

  // @option の型を非Nullableにすると必須キーワードになります
  @option(short: 'f', long: 'format', description: '入出力する形式を指定します')
  // enum型を指定することができます
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

enum Format {
  csv,
  json,
}
```

上で定義したクラスを import して main 関数の引数をクラスのコンストラクタの引数にそのまま渡します。

```dart
import "../csv_reader_example.dart";
import 'dart:io';

void main(List<String> arguments) {
  CsvReaderExample args = CsvReaderExample(arguments);
  File file = File(args.fileName);
  List<String> lines = file.readAsLinesSync();
  if (!args.hasHeader) {
    lines.removeAt(0);
  }

  List<String> outputLines = lines.getRange(0, args.limit).toList();

  String extension;
  if (args.format == Format.csv) {
    extension = ".csv";
  } else if (args.format == Format.json) {
    extension = ".json";
  } else {
    extension = ".txt";
  }

  if (args.optionFileNames != null) {
    for (String outputFileName in args.optionFileNames!) {
      File output = File(outputFileName + extension);
      output.writeAsString(outputLines.join("\n"));
    }
  }
}
```

## Example

`/example` ディレクトリ以下の例を参照ください。

```dart
const like = 'sample';
```

## Additional information

徐々にREADMEやexampleを充実させるつもりですが、ドキュメントを英訳にする自信がないので、
翻訳くらいなら手伝ってあげてもいいよという方がいらっしゃいましたら、Issueなどでご連絡いただければうれしいです🙏

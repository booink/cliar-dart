import "../csv_reader_example.dart";
import 'dart:io';

void main(List<String> arguments) {
  CsvReaderExample args = CsvReaderExample(arguments, canPrintUsage: true, canExit: true);
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
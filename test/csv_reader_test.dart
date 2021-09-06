import 'package:cliar/cliar.dart';
import "../example/csv_reader_example.dart";
import 'package:test/test.dart';

void main() {
  group('All arguments are given', () {
    List<String> arguments = [
      "/path/to/required.file",
      "/path/to/option.file1", "/path/to/option.file2",
      "-f", "csv",
      "-o", "/path/to/output.file",
      "-l", "5",
      "-h",
      "-v",
      "-v",
      "-v"
    ];

    final csvReader = CsvReaderExample(arguments);

    test('Required positional variable was set', () {
      expect(csvReader.fileName, "/path/to/required.file");
    });

    test('Positional variable was set', () {
      expect(csvReader.optionFileNames!, ["/path/to/option.file1", "/path/to/option.file2"]);
    });

    test('Required option variable was set', () {
      expect(csvReader.format, Format.csv);
    });

    test('Option variable was set', () {
      expect(csvReader.output!, "/path/to/output.file");
    });

    test('Flag variable was set', () {
      expect(csvReader.limit, 5);
    });

    test('List flags variable was set', () {
      expect(csvReader.verbose, 3);
    });
  });

  group('All long arguments are given', () {
    List<String> arguments = [
      "/path/to/required.file",
      "/path/to/option.file1", "/path/to/option.file2",
      "--format", "csv",
      "--output-file-name", "/path/to/output.file",
      "--limit", "5",
      "-h",
      "-v"
    ];

    final csvReader = CsvReaderExample(arguments);

    test('Required positional variable was set', () {
      expect(csvReader.fileName, "/path/to/required.file");
    });

    test('Positional variable was set', () {
      expect(csvReader.optionFileNames!, ["/path/to/option.file1", "/path/to/option.file2"]);
    });

    test('Required option variable was set', () {
      expect(csvReader.format, Format.csv);
    });

    test('Option variable was set', () {
      expect(csvReader.output!, "/path/to/output.file");
    });

    test('Flag variable was set', () {
      expect(csvReader.limit, 5);
    });

    test('List flags variable was set', () {
      expect(csvReader.verbose, 1);
    });
  });

  group('Required arguments are missing', () {
    List<String> arguments = [
      "--output-file-name", "/path/to/output.file",
      "--limit", "5",
      "-h",
      "-v"
    ];

    test('Required positional variable was not set', () {
      expect(() => CsvReaderExample(arguments), throwsA(TypeMatcher<CliarArgumentsException>()));
    });
  });

  group('Optional arguments are missing', () {
    List<String> arguments = [
      "/path/to/required.file",
      "-f", "csv",
    ];

    final csvReader = CsvReaderExample(arguments);

    test('Required positional variable was set', () {
      expect(csvReader.fileName, "/path/to/required.file");
    });

    test('Positional variable was set to null', () {
      expect(csvReader.optionFileNames, null);
    });

    test('Required option variable was set', () {
      expect(csvReader.format, Format.csv);
    });

    test('Option variable was set to null', () {
      expect(csvReader.output, null);
    });

    test('Flag variable was set to default', () {
      expect(csvReader.limit, 10);
    });

    test('List flags variable was set empty list', () {
      expect(csvReader.verbose, 0);
    });
  });
}
import 'dart:io';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:csv/csv.dart';
import 'package:flutterl10nmanager/entities/localisation.dart';
import 'package:flutterl10nmanager/manager.dart';

class CreateCommand extends Command {
  final name = 'create';
  final description = 'Creates ARB files from a CSV';

  final _log = Logger();

  CreateCommand() {
    //argParser.addOption('test');
  }

  void run() async {
    // Validate the path
    final String csvPath = argResults.rest[0];
    if (FileSystemEntity.typeSync(csvPath) == FileSystemEntityType.notFound) {
      _log.error('Path not found.');
      return;
    }

    // Parse the CSV 
    final List<List<dynamic>> rows = const CsvToListConverter().convert(await File(csvPath).readAsString(), fieldDelimiter: '|');

    // Validate the data structure
    List headers = rows.first;
    rows.removeAt(0);
    if (headers.length < 5) {
      _log.error('Incorrect CSV format. Expected: id|description|type|placeholders|countryCode[|countryCode...]');
      return;
    }

    List<String> languages = List.from(headers)..removeRange(0, 4);
    print(languages);

    // Get an instance of the manager
    LocalisationsManager manager = LocalisationsManager();
    rows.forEach((List row) {
      manager.addLocalisation(Localisation(
        id: row[0],
        description: row[1],
        type: row[2],
        placeholders: jsonDecode(row[3]),
      ));
      List<String> missingLangs = [];
      for (int i = 0; i < languages.length; i++) {
        if (row[i + 4].length == 0) {
          missingLangs.add(languages[i]);
        } else {
          manager.addValueForLocalisation(languages[i], row[0], row[i + 4]);
        }
      }
      if (missingLangs.isNotEmpty) {
        _log.info('Warning! Missing langauge values [' + missingLangs.join(', ') + '] for: ' + row[0]);
      }
    });

    for (String lang in languages) {
      String fileName = 'intl_$lang.arb';
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      await File(fileName).writeAsString(
        encoder.convert(manager.generateArb(lang))
      );
      _log.success('Successfully created ARB for ${lang}: ${fileName}');
    }
  }
}

String getFileNameFromPath(String path) =>
  path.split('/').last;

String getLangFromFileName(String fileName) =>
  fileName.substring(5, fileName.length - 4);


class Logger { 
  AnsiPen pen = AnsiPen();
  
  void error(String message) {
    pen..red();
    print(pen(message));
  }

  void success(String message) {
    pen..green();
    print(pen(message));
  }

  void info(String message) => print(message);
}
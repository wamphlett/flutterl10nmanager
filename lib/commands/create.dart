import 'dart:io';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:csv/csv.dart';
import 'package:flutterl10nmanager/entities/localisation.dart';
import 'package:flutterl10nmanager/manager.dart';
import 'package:flutterl10nmanager/helpers.dart';

/// Takes a 
class CreateCommand extends Command {
  final name = 'create';
  final description = 'Creates ARB files from a CSV';

  final _log = Logger();

  CreateCommand() {
    argParser.addOption(
      'output-path', 
      abbr: 'o', 
      defaultsTo: './',
      help: 'A path to the desired output location'
    );
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
    if (
      headers.length < 5 ||
      headers[0] != 'id' ||
      headers[1] != 'description' ||
      headers[2] != 'type' ||
      headers[3] != 'placeholders'
    ) {
      _log.error('Incorrect CSV format. Expected: id|description|type|placeholders|countryCode[|countryCode...]');
      return;
    }

    List<String> languages = List.from(headers)..removeRange(0, 4);
    _log.info('Parsing ${rows.length} rows for ${languages.length} languages: [${languages.join(', ')}]');

    // Get an instance of the manager
    LocalisationsManager manager = LocalisationsManager();
    // Create a localisation for each row and add its available values
    int rowsWithMissingValues = 0;
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
        rowsWithMissingValues++;
        _log.warning('Warning! Missing langauge values [' + missingLangs.join(', ') + '] for: ' + row[0]);
      }
    });

    for (String lang in languages) {
      String fileName = 'intl_$lang.arb';
      String outputPath = argResults['output-path'].endsWith('/') 
        ? argResults['output-path'] 
        : argResults['output-path'] + '/';
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      await File(outputPath + fileName).writeAsString(
        encoder.convert(manager.generateArb(lang))
      );
      _log.success('Successfully created ARB for ${lang}: ${outputPath + fileName}');
    }

    // Show warnings
    if (rowsWithMissingValues > 0) {
      _log.warning('Warning. There are ${rowsWithMissingValues} localisations that are missing values!');
      exitCode = 1;
    }
  }
}

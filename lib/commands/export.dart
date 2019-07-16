import 'dart:io';
import 'dart:convert';
import 'package:args/command_runner.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutterl10nmanager/entities/localisation.dart';
import 'package:flutterl10nmanager/manager.dart';


class ExportCommand extends Command {
  final name = 'export';
  final description = 'Exports the current translations to a single CSV';

  final _log = Logger();

  ExportCommand() {
    //argParser.addOption('test');
  }

  void run() async {

    final String l10nPath = argResults.rest[0].endsWith('/') ? argResults.rest[0] : argResults.rest[0] + '/';
    if (FileSystemEntity.typeSync(l10nPath + LocalisationsManager.messageFileName) == FileSystemEntityType.notFound) {
      _log.error('Unable to find a flutter message file in the given dir. Giving up.');
      return;
    }

    // Start a new instance of the manager
    LocalisationsManager manager = LocalisationsManager();
    // Create the resources
    await File(l10nPath + LocalisationsManager.messageFileName)
      .readAsString()
      .then((fileContents) => jsonDecode(fileContents))
      .then((jsonData) {
        jsonData.keys.forEach((String e) {
          if (e.startsWith('@') && LocalisationsManager.isValidResourceObject(jsonData[e])) { 
            manager.addLocalisation(Localisation(
              id: e.substring(1),
              description: jsonData[e]['description'],
              type: jsonData[e]['type'],
              placeholders: jsonData[e]['placeholders'],
            ));
          }
        });
      });
      
    // Now find all the language specific files
    Directory dir = Directory(l10nPath);
    Map<String, String> localisationFiles = {};
    dir.listSync().forEach((f) {
      final String fileName = getFileNameFromPath(f.path);
      RegExp pattern = RegExp(r'intl_([a-z]{0,3})\.arb');
      if (pattern.hasMatch(fileName)) {
        localisationFiles[pattern.firstMatch(fileName).group(1)] = fileName;
      }
    });

    for (String lang in localisationFiles.keys) {
      await File(l10nPath + localisationFiles[lang])
        .readAsString()
        .then((fileContents) => jsonDecode(fileContents))
        .then((jsonData) {
          jsonData.keys.forEach((String e) {
            if (e.startsWith('@')) {
              return;
            }
            manager.addValueForLocalisation(lang, e, jsonData[e]);
          });
        });
    }

    String exportName = 'flutterl10n-export.csv';
    await File(exportName).writeAsString(manager.getAsCSV());

    _log.success("Successfully exported data to CSV: ${exportName}");
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
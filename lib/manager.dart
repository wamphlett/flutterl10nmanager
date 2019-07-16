import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutterl10nmanager/entities/localisation.dart';
import 'package:intl/intl.dart';

class LocalisationsManager {
  static final String messageFileName = 'intl_messages.arb';
  final Map<String, Localisation> localisations = {};

  LocalisationsManager();

  void addLocalisation(Localisation localisation) {
    localisations[localisation.id] = localisation;
  }

  void addValueForLocalisation(String lang, String localisationId, String value) {
    if (localisations[localisationId] == null) {
      print("MISSING LOCALISATION: ${localisationId}");
      return;
    }
    localisations[localisationId].setLanguageValue(lang, value);
  }

  String getAsCSV() {
    List<String> languages = getLanguages();
    List<List<dynamic>> rows = [];
    // Build headers
    List<String> headers = ['id', 'description', 'type', 'placeholders'];
    languages.forEach((lang) => headers.add(lang));
    rows.add(headers);
    // Build each localisation
    localisations.forEach((localisationId, localisation) {
      List<String> row = [
        localisation.id,
        localisation.description,
        localisation.type,
        jsonEncode(localisation.placeholders)
      ];
      languages.forEach((lang) => row.add(localisation.valueForLang(lang) ?? ''));
      rows.add(row);
    });

    return ListToCsvConverter().convert(rows, fieldDelimiter: '|');
  }

  Map<String, dynamic> generateArb(String lang) {
    Map<String, dynamic> arb = {
      '@@last_modified': DateFormat('y-MM-ddTHH:mm:ss.S').format(DateTime.now())
    };
    localisations.forEach((localisationId, localisation) {
      String langValue = localisation.valueForLang(lang);
      if (langValue != null) {
        arb[localisation.id] = langValue;
        arb['@' + localisation.id] = {
          'description': localisation.description,
          'type': localisation.type,
          'placeholders': localisation.placeholders,
        };
      }
    });
    return arb;
  }

  List<String> getLanguages() {
    final List<String> languages = [];
    localisations.forEach((k, localisation) {
      localisation.values.forEach((k, value) {
        if (languages.contains(value.lang) == false) {
          languages.add(value.lang);
        }
      });
    });

    return languages;
  }

  static bool isValidResourceObject(dynamic resource) {
    return resource is Map
      && resource['description'] != null
      && resource['type'] != null
      && resource['placeholders'] != null;
  }
}
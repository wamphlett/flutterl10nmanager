import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:flutterl10nmanager/entities/localisation.dart';
import 'package:flutterl10nmanager/helpers.dart';

class LocalisationsManager {
  static final String messageFileName = 'intl_messages.arb';
  final Map<String, Localisation> localisations = {};
  final _log = Logger();

  /// Adds a new [Localisation] for the manager to keep track of
  void addLocalisation(Localisation localisation) {
    localisations[localisation.id] = localisation;
  }

  /// Takes a new [value] for the given [lang] and adds it to the appropriate
  /// [Localisation] based on the [localisationId].
  void addValueForLocalisation(
      String lang, String localisationId, String value) {
    if (localisations[localisationId] == null) {
      _log.warning(
          "Warning! Missing localisation for ${localisationId}. Value not added.");
      return;
    }
    localisations[localisationId].setLanguageValue(lang, value);
  }

  /// Returns the current contents of the manager in CSV format
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
      languages
          .forEach((lang) => row.add(localisation.valueForLang(lang) ?? ''));
      rows.add(row);
    });

    return ListToCsvConverter().convert(rows, fieldDelimiter: '|');
  }

  /// Generates an arb object for the given [lang]
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

  /// Returns a list of all the language values the manager
  /// knows about.
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

  /// Basic validation of arb resources
  static bool isValidResourceObject(dynamic resource) {
    return resource is Map &&
        resource['description'] != null &&
        resource['type'] != null &&
        resource['placeholders'] != null;
  }
}

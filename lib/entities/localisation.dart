class Localisation {
  final String id;
  final String description;
  final String type;
  final Map<String, dynamic> placeholders;
  Localisation({this.id, this.description, this.type, this.placeholders});

  Map<String, LocalisationValue> values = Map();

  void setLanguageValue(String lang, String value) {
    values[lang] = LocalisationValue(lang, value);
  }

  String valueForLang(String lang) =>
      values[lang] != null ? values[lang].value : null;
}

class LocalisationValue {
  final String lang;
  final String value;
  LocalisationValue(this.lang, this.value);
}

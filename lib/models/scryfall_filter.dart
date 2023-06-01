class ScryfallFilter {
  String? searchTerm;
  List<String>? languages;
  String? creatureType;
  String? cardType;
  String? set;
  String? cmcValue;
  String? cmcCondition;
  Map<String, bool>? colors;

  ScryfallFilter({
    required this.searchTerm,
    required this.languages,
    required this.creatureType,
    required this.cardType,
    required this.set,
    required this.cmcValue,
    required this.cmcCondition,
    required this.colors,
  });

  factory ScryfallFilter.fromMap(Map<String, dynamic> map) {
    return ScryfallFilter(
      searchTerm: map['searchTerm'],
      languages: map['languages'],
      creatureType: map['creatureType'],
      cardType: map['cardType'],
      set: map['set'],
      cmcValue: map['cmcValue'],
      cmcCondition: map['cmcCondition'],
      colors: map['colors'],
    );
  }

  String baseQuery() {
    return 'unique=cards&order=name&dir=asc&include_multilingual=1&include_variations=1&include_extras=1&format=json&pretty=true';
  }

  String toQuery() {
    // your logic here to transform the filter options to a string
    // that can be sent as a query string to Scryfall.
    // Note: You need to handle the color map specially.
    // For example:
    String? colorQuery = colors?.entries
        .where((element) => element.value == true)
        .map((e) => e.key)
        .join("");
    return "q=$searchTerm&${baseQuery()}&type=$cardType&type=$creatureType&set=$set&cmc=$cmcCondition$cmcValue&color=$colorQuery";
  }
}

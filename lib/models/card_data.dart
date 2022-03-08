class CardData {
  late String id;
  late String name;
  late String text;
  late List<String> images;
  late bool hasTwoSides;
  late Map<String, dynamic> price;

  CardData({
    required this.id,
    required this.name,
    required this.text,
    required this.images,
    required this.hasTwoSides,
    required this.price,
  });

  CardData.fromMap(Map<String, Map<String, Object>> map) {
    final searchValues = map["search_values"];
    final imageValues = map["imageValues"];
    final priceValues = map["priceValues"];
    id = searchValues!["id"].toString() ?? '';
    name = searchValues["name"].toString() ?? '';
    text = searchValues["text"].toString() ?? '';
    hasTwoSides = searchValues["hasTwoSides"] == 1 ? true : false;
    images = [
      imageValues!["frontImage"].toString(),
      (imageValues["backImage"] != '' && imageValues["backImage"] != null)
          ? imageValues["backImage"].toString()
          : ''
    ];
    price = {
      'tcg': priceValues!["tcg"],
      'tcg_foil': priceValues["tcgFoil"],
      'cardmarket': priceValues["cdm"],
      'cardmarket_foil': priceValues["cdmFoil"],
    };
  }

  Map<String, Map<String, Object?>> toDB(CardData cardData, String searchText) {
    final searchValues = {
      'searchText': searchText,
      'id': cardData.id,
      'name': cardData.name,
      'text': cardData.text,
      'hasTwoSides': cardData.hasTwoSides ? 1 : 0,
    };
    final imageValues = {
      'searchText': searchText,
      'id': cardData.id,
      'frontImage': cardData.images[0],
      'backImage': cardData.hasTwoSides ? cardData.images[1] : '',
    };
    final priceValues = {
      'searchText': searchText,
      'id': cardData.id,
      'tcg': cardData.price['tcg'],
      'tcgFoil': cardData.price['tcg_foil'],
      'cdm': cardData.price['cardmarket'],
      'cdmFoil': cardData.price['cardmarket_foil'],
    };
    return {
      'user_searches': searchValues,
      'search_images': imageValues,
      'search_prices': priceValues,
    };
  }
}

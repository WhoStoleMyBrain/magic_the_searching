import 'dart:ffi';

class CardData {
  late String id;
  late String name;
  late String text;
  late List<String> images;
  late bool hasTwoSides;
  late Map<String, dynamic> price;
  late DateTime dateTime;
  late Map<String, String> links;

  CardData(
      {required this.id,
      required this.name,
      required this.text,
      required this.images,
      required this.hasTwoSides,
      required this.price,
      required this.dateTime,
      required this.links});

  CardData.fromMap(Map<String, Map<String, dynamic>> map) {
    final searchValues = map['user_searches'];
    final imageValues = map["search_images"];
    final priceValues = map["search_prices"];
    final linksValues = map["search_links"];
    // print(searchValues);
    id = searchValues?["id"].toString() ?? '';
    name = searchValues?["name"].toString() ?? '';
    text = searchValues?["text"].toString() ?? '';
    // print(searchValues?["hasTwoSides"]);
    // print(searchValues?["hasTwoSides"] ?? false);
    // print((searchValues?["hasTwoSides"] ?? false) == 1);
    hasTwoSides = ((searchValues?["hasTwoSides"] ?? false) == 1) ? true : false;
    dateTime = DateTime.parse(searchValues?["requestTime"].toString() ?? '');
    images = [
      imageValues?["frontImage"].toString() ?? '',
      ((imageValues?["backImage"] ?? '') != '' &&
              (imageValues?["backImage"]) != null)
          ? imageValues!["backImage"].toString()
          : ''
    ];
    // print(images);
    price = {
      'tcg': priceValues?["tcg"] ?? '--.--',
      'tcg_foil': priceValues?["tcgFoil"] ?? '--.--',
      'cardmarket': priceValues?["cdm"] ?? '--.--',
      'cardmarket_foil': priceValues?["cdmFoil"] ?? '--.--',
    };
    links = {
      'tcg': linksValues?['tcg'] ?? '',
      'cardmarket': linksValues?['cardmarket'] ?? '',
      'scryfall': linksValues?['scryfall'] ?? '',
    };
  }

  Map<String, Map<String, Object?>> toDB(
      CardData cardData, String searchText, bool isFromVersions) {
    var today = cardData.dateTime.toIso8601String();

    // var today = DateTime.now().subtract(const Duration(days: 9)).toIso8601String();
    final searchValues = {
      'searchText': searchText,
      'id': cardData.id,
      'name': cardData.name,
      'text': cardData.text,
      'hasTwoSides': cardData.hasTwoSides ? 1 : 0,
      'requestTime': today,
      'isFromVersions': isFromVersions ? 1 : 0,
      // 'requestTime': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
    };
    final imageValues = {
      'searchText': searchText,
      'id': cardData.id,
      'frontImage': cardData.images[0],
      'backImage': cardData.hasTwoSides ? cardData.images[1] : '',
      'requestTime': today,
    };
    final priceValues = {
      'searchText': searchText,
      'id': cardData.id,
      'tcg': cardData.price['tcg'],
      'tcgFoil': cardData.price['tcg_foil'],
      'cdm': cardData.price['cardmarket'],
      'cdmFoil': cardData.price['cardmarket_foil'],
      'requestTime': today,
    };
    final links = {
      'searchText': searchText,
      'id': cardData.id,
      'tcg': cardData.price['tcg'],
      'cardmarket': cardData.price['cardmarket'],
      'scryfall': cardData.price['scryfall'],
      'requestTime': today,
    };
    return {
      'user_searches': searchValues,
      'search_images': imageValues,
      'search_prices': priceValues,
      'search_links': links,
    };
  }
}

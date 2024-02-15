import 'package:json_annotation/json_annotation.dart';
import 'package:magic_the_searching/helpers/constants.dart';
import './prices.dart';
import './purchase_uris.dart';

import 'image_uris.dart';

// import 'card_faces.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'card_info.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
List<ImageUris?>? cardFacesFromJson(List<dynamic>? json) {
  List<ImageUris?>? tmp = [];
  if (json != null) {
    for (Map<String, dynamic> element in json) {
      tmp.add(element['image_uris'] == null
          ? null
          : ImageUris.fromJson(element['image_uris'] as Map<String, dynamic>));
    }
  } else {
    tmp = null;
  }
  return tmp;
}

List<ImageUris?>? cardFacesFromDB(Map<String, dynamic> dbData) {
  Map<String, dynamic> frontImages = {
    'normal': dbData['normalFront'],
    'small': dbData['smallFront']
  };
  Map<String, dynamic> backImages = {
    'normal': dbData['normalBack'],
    'small': dbData['smallBack']
  };
  return [ImageUris.fromJson(frontImages), ImageUris.fromJson(backImages)];
}

Map<String, dynamic> cardFacesToJson(List<ImageUris?>? instance) {
  Map<String, dynamic> returnValue = {};
  returnValue['card_faces'] = instance?.map((e) => e?.toJson());
  return returnValue;
}

bool hasTwoSidesFromJson(List<dynamic>? json) {
  return json?[0]['value'];
}

Map<String, dynamic> hasTwoSidesToJson(bool instance) {
  return {'value': instance.toString()};
}

List<dynamic>? hasTwoSidesReadValue(
    Map<dynamic, dynamic>? json, String parameterName) {
  return json?['card_faces'] == null
      ? [
          {'value': false}
        ]
      : [
          {'value': true}
        ];
}

DateTime dateTimeFromJson(List<dynamic>? json) {
  return DateTime.parse(json?[0]);
}

Map<String, dynamic> dateTimeToJson(DateTime instance) {
  return {'dateTime': instance.toIso8601String()};
}

List<dynamic>? dateTimeReadValue(
    Map<dynamic, dynamic>? json, String parameterName) {
  return [DateTime.now().toIso8601String()];
}

String? oracleTextReadValue(Map<dynamic, dynamic>? json, String parameterName) {
  return (json?['card_faces'] == null)
      ? (json?['oracle_text'] == null)
          ? null
          : json!['oracle_text']
      : json?['card_faces']
          .map((e) => e['oracle_text'])
          .join(Constants.placeholderSplitText);
}

String? printedTextReadValue(
    Map<dynamic, dynamic>? json, String parameterName) {
  return (json?['card_faces'] == null)
      ? (json?['printed_text'] == null)
          ? null
          : json!['printed_text']
      : json?['printed_faces']
          .map((e) => e['printed_text'])
          .join(Constants.placeholderSplitText);
}

String? powerToughnessLoyaltyReadValue(
    Map<dynamic, dynamic>? json, String parameterName) {
  return (json?['card_faces'] == null)
      ? (json?[parameterName] == null)
          ? null
          : json![parameterName]
      : (json?['card_faces'].first[parameterName] == null &&
              json?['card_faces'].last[parameterName] == null)
          ? null
          : json?['card_faces']
              .map((e) => e[parameterName])
              .join(Constants.placeholderSplitText);
}

@JsonSerializable(
    explicitToJson:
        true, // makes subclasses usable in the toJson method. otherwise would get "Instance of..."
    fieldRename:
        FieldRename // renames the fields from the Json to lowerCamelCase variables
            .snake)
class CardInfo {
  //flutter pub run build_runner watch // deprecated!
  // dart run build_runner build
  CardInfo({
    required this.id,
    required this.name,
    required this.printedName,
    required this.manaCost,
    required this.typeLine,
    required this.printedTypeLine,
    required this.oracleId,
    required this.oracleText,
    required this.printedText,
    required this.power,
    required this.toughness,
    required this.loyalty,
    required this.setName,
    required this.flavorText,
    required this.scryfallUri,
    required this.imageUris,
    required this.cardFaces,
    required this.prices,
    required this.purchaseUris,
    required this.hasTwoSides,
    required this.dateTime,
  });
  String id;
  String? name;
  String? printedName;
  String? manaCost;
  String? typeLine;
  String? printedTypeLine;
  @JsonKey(name: 'oracle_id')
  String? oracleId;
  @JsonKey(name: 'oracleText', readValue: oracleTextReadValue)
  String? oracleText;
  @JsonKey(name: 'printedText', readValue: printedTextReadValue)
  String? printedText;
  @JsonKey(
    readValue: powerToughnessLoyaltyReadValue,
  )
  String? power;
  @JsonKey(
    readValue: powerToughnessLoyaltyReadValue,
  )
  String? toughness;
  @JsonKey(
    readValue: powerToughnessLoyaltyReadValue,
  )
  String? loyalty;
  String? setName;
  String? flavorText;
  @JsonKey(name: 'scryfall_uri')
  String? scryfallUri;
  ImageUris? imageUris;
  Prices? prices;
  @JsonKey(name: 'purchase_uris')
  PurchaseUris? purchaseUris;
  @JsonKey(
      readValue: hasTwoSidesReadValue,
      name:
          'hasTwoSides', // note: this key should NOT exist in the json from the API. refer to functions for more information
      fromJson: hasTwoSidesFromJson,
      toJson: hasTwoSidesToJson)
  bool hasTwoSides; // Can I even add this here?
  @JsonKey(fromJson: cardFacesFromJson, toJson: cardFacesToJson)
  List<ImageUris?>? cardFaces;
  @JsonKey(
      name: 'test',
      readValue: dateTimeReadValue,
      fromJson: dateTimeFromJson,
      toJson: dateTimeToJson)
  DateTime dateTime; // how to add this here?

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory CardInfo.fromJson(Map<String, dynamic> json) =>
      _$CardInfoFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$CardInfoToJson(this);

  factory CardInfo.fromDB(Map<String, dynamic> dbData) {
    return CardInfo(
      id: dbData['card_info']['id'] as String,
      name: dbData['card_detail']['name'] as String?,
      printedName: dbData['card_detail']['printedName'] as String?,
      oracleId: dbData['card_info']['oracleId'] as String?,
      oracleText: dbData['card_detail']['oracleText'] as String?,
      printedText: dbData['card_detail']['printedText'] as String?,
      setName: dbData['card_detail']['setName'] as String?,
      scryfallUri: dbData['card_info']['scryfallUri'] as String?,
      imageUris: ImageUris.fromDB(dbData['image_uris']),
      cardFaces: cardFacesFromDB(dbData['card_faces']),
      prices: Prices.fromDB(dbData['prices']),
      purchaseUris: PurchaseUris.fromDB(dbData['purchase_uris']),
      hasTwoSides: dbData['card_detail']['hasTwoSides'] == 0 ? false : true,
      dateTime: DateTime.parse(dbData['card_info']['dateTime'] as String),
      flavorText: dbData['card_detail']['flavorText'] as String?,
      manaCost: dbData['card_detail']['manaCost'] as String?,
      power: dbData['card_detail']['power'] as String?,
      toughness: dbData['card_detail']['toughness'] as String?,
      loyalty: dbData['card_detail']['loyalty'] as String?,
      typeLine: dbData['card_detail']['typeLine'] as String?,
      printedTypeLine: dbData['card_detail']['printedTypeLine'] as String?,
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'card_info': {
        'id': id,
        'oracleId': oracleId,
        'scryfallUri': scryfallUri,
        'dateTime': dateTime.toIso8601String(),
      },
      'card_detail': {
        'id': id,
        'name': name,
        'printedName': printedName,
        'manaCost': manaCost,
        'typeLine': typeLine,
        'printedTypeLine': printedTypeLine,
        'oracleText': oracleText,
        'printedText': printedText,
        'power': power,
        'toughness': toughness,
        'loyalty': loyalty,
        'setName': setName,
        'flavorText': flavorText,
        'hasTwoSides': hasTwoSides ? 1 : 0,
      },
      'image_uris': {
        'id': id,
        'normal': imageUris?.normal,
        'small': imageUris?.small,
      },
      'card_faces': {
        'id': id,
        'normalFront': cardFaces?[0]?.normal,
        'smallFront': cardFaces?[0]?.small,
        'normalBack': cardFaces?[1]?.normal,
        'smallBack': cardFaces?[1]?.small,
      },
      'prices': {
        'id': id,
        'usd': prices?.usd,
        'usdFoil': prices?.usdFoil,
        'eur': prices?.eur,
        'eurFoil': prices?.eurFoil,
      },
      'purchase_uris': {
        'id': id,
        'tcgplayer': purchaseUris?.tcgplayer,
        'cardmarket': purchaseUris?.cardmarket,
      }
    };
  }
}

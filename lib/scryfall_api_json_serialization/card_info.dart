import 'package:json_annotation/json_annotation.dart';
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
List<ImageLinks?>? cardFacesFromJson(List<dynamic>? json) {
  List<ImageLinks?>? tmp = [];
  if (json != null) {
    for (Map<String, dynamic> element in json) {
      tmp.add(element['image_uris'] == null
          ? null
          : ImageLinks.fromJson(element['image_uris'] as Map<String, dynamic>));
    }
  } else {
    tmp = null;
  }
  return tmp;
}

Map<String, dynamic> cardFacesToJson(List<ImageLinks?>? instance) {
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

List<dynamic>? hasTwoSidesReadValue(Map<dynamic, dynamic>? json, String parameterName) {
  return json?['card_faces'] == null ? [{'value': false}] : [{'value':true}];
}

//dateTime

DateTime dateTimeFromJson(List<dynamic>? json) {
  return DateTime.parse(json?[0]);
}

Map<String, dynamic> dateTimeToJson(DateTime instance) {
  return {'dateTime': instance.toIso8601String()};
}

List<dynamic>? dateTimeReadValue(Map<dynamic, dynamic>? json, String parameterName) {
  return [DateTime.now().toIso8601String()];
}

@JsonSerializable(
    explicitToJson:
        true, // makes subclasses usable in the toJson method. otherwise would get "Instance of..."
    fieldRename:
        FieldRename // renames the fields from the Json to lowerCamelCase variables
            .snake)
class CardInfo {
  //flutter pub run build_runner watch
  CardInfo({
    required this.id,
    required this.name,
    required this.oracleId,
    required this.oracleText,
    required this.scryfallUri,
    required this.imageUris,
    required this.cardFaces,
    // required this.hasTwoSides,
    required this.prices,
    // required this.dateTime,
    required this.purchaseUris,
    required this.hasTwoSides,
    required this.dateTime,
  });
  String id;
  String? name;
  String? oracleId;
  String? oracleText;
  String? scryfallUri;
  ImageLinks? imageUris;
  Prices? prices;
  PurchaseUris? purchaseUris;
  @JsonKey(
      readValue: hasTwoSidesReadValue,
      name: 'hasTwoSides', // note: this key should NOT exist in the json from the API. refer to functions for more information
      fromJson: hasTwoSidesFromJson,
      toJson: hasTwoSidesToJson)
  bool hasTwoSides; // Can I even add this here?
  @JsonKey(fromJson: cardFacesFromJson, toJson: cardFacesToJson)
  List<ImageLinks?>? cardFaces;
  @JsonKey(name: '', readValue: dateTimeReadValue, fromJson: dateTimeFromJson, toJson: dateTimeToJson)
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
}

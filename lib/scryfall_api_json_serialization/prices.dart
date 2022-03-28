import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'prices.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class Prices {
  Prices({
    required this.usd,
    required this.usdFoil,
    required this.eur,
    required this.eurFoil,
  });
  String? usd;
  @JsonKey(name: 'usd_foil')
  String? usdFoil;
  String? eur;
  @JsonKey(name: 'eur_foil')
  String? eurFoil;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Prices.fromJson(Map<String, dynamic> json) => _$PricesFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$PricesToJson(this);

  factory Prices.fromDB(Map<String, dynamic>? dbData) {
    return Prices(
      usd: dbData?['usd'],
      usdFoil: dbData?['usdFoil'],
      eur: dbData?['eur'],
      eurFoil: dbData?['eurFoil'],
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardInfo _$CardInfoFromJson(Map<String, dynamic> json) => CardInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      printedName: json['printed_name'] as String?,
      manaCost: json['mana_cost'] as String?,
      typeLine: json['type_line'] as String?,
      printedTypeLine: json['printed_type_line'] as String?,
      oracleId: json['oracle_id'] as String?,
      oracleText: oracleTextReadValue(json, 'oracleText') as String?,
      printedText: printedTextReadValue(json, 'printedText') as String?,
      power: powerToughnessLoyaltyReadValue(json, 'power') as String?,
      toughness: powerToughnessLoyaltyReadValue(json, 'toughness') as String?,
      loyalty: powerToughnessLoyaltyReadValue(json, 'loyalty') as String?,
      setName: json['set_name'] as String?,
      flavorText: json['flavor_text'] as String?,
      scryfallUri: json['scryfall_uri'] as String?,
      imageUris: json['image_uris'] == null
          ? null
          : ImageUris.fromJson(json['image_uris'] as Map<String, dynamic>),
      cardFaces: cardFacesFromJson(json['card_faces'] as List?),
      prices: json['prices'] == null
          ? null
          : Prices.fromJson(json['prices'] as Map<String, dynamic>),
      purchaseUris: json['purchase_uris'] == null
          ? null
          : PurchaseUris.fromJson(
              json['purchase_uris'] as Map<String, dynamic>),
      hasTwoSides: hasTwoSidesFromJson(
          hasTwoSidesReadValue(json, 'hasTwoSides') as List?),
      dateTime: dateTimeFromJson(dateTimeReadValue(json, 'test') as List?),
    );

Map<String, dynamic> _$CardInfoToJson(CardInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'printed_name': instance.printedName,
      'mana_cost': instance.manaCost,
      'type_line': instance.typeLine,
      'printed_type_line': instance.printedTypeLine,
      'oracle_id': instance.oracleId,
      'oracleText': instance.oracleText,
      'printedText': instance.printedText,
      'power': instance.power,
      'toughness': instance.toughness,
      'loyalty': instance.loyalty,
      'set_name': instance.setName,
      'flavor_text': instance.flavorText,
      'scryfall_uri': instance.scryfallUri,
      'image_uris': instance.imageUris?.toJson(),
      'prices': instance.prices?.toJson(),
      'purchase_uris': instance.purchaseUris?.toJson(),
      'hasTwoSides': hasTwoSidesToJson(instance.hasTwoSides),
      'card_faces': cardFacesToJson(instance.cardFaces),
      'test': dateTimeToJson(instance.dateTime),
    };

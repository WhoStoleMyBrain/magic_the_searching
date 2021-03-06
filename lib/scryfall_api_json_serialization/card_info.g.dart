// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardInfo _$CardInfoFromJson(Map<String, dynamic> json) => CardInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      oracleId: json['oracle_id'] as String?,
      oracleText: oracleTextReadValue(json, 'oracleText') as String?,
      setName: json['set_name'] as String?,
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
      'oracle_id': instance.oracleId,
      'oracleText': instance.oracleText,
      'set_name': instance.setName,
      'scryfall_uri': instance.scryfallUri,
      'image_uris': instance.imageUris?.toJson(),
      'prices': instance.prices?.toJson(),
      'purchase_uris': instance.purchaseUris?.toJson(),
      'hasTwoSides': hasTwoSidesToJson(instance.hasTwoSides),
      'card_faces': cardFacesToJson(instance.cardFaces),
      'test': dateTimeToJson(instance.dateTime),
    };

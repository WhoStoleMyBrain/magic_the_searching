// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardInfo _$CardInfoFromJson(Map<String, dynamic> json) => CardInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      oracleId: json['oracle_id'] as String?,
      oracleText: json['oracle_text'] as String?,
      scryfallUri: json['scryfall_uri'] as String?,
      imageUris: json['image_uris'] == null
          ? null
          : ImageLinks.fromJson(json['image_uris'] as Map<String, dynamic>),
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
      dateTime: dateTimeFromJson(dateTimeReadValue(json, '') as List?),
    );

Map<String, dynamic> _$CardInfoToJson(CardInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'oracle_id': instance.oracleId,
      'oracle_text': instance.oracleText,
      'scryfall_uri': instance.scryfallUri,
      'image_uris': instance.imageUris?.toJson(),
      'prices': instance.prices?.toJson(),
      'purchase_uris': instance.purchaseUris?.toJson(),
      'hasTwoSides': hasTwoSidesToJson(instance.hasTwoSides),
      'card_faces': cardFacesToJson(instance.cardFaces),
      '': dateTimeToJson(instance.dateTime),
    };

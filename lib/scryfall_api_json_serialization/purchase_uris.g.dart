// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_uris.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseUris _$PurchaseUrisFromJson(Map<String, dynamic> json) => PurchaseUris(
      tcgplayer: json['oracle_id'] as String?,
      cardmarket: json['cardmarket'] as String?,
    );

Map<String, dynamic> _$PurchaseUrisToJson(PurchaseUris instance) =>
    <String, dynamic>{
      'oracle_id': instance.tcgplayer,
      'cardmarket': instance.cardmarket,
    };

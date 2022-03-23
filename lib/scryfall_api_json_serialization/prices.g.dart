// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prices.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prices _$PricesFromJson(Map<String, dynamic> json) => Prices(
      usd: json['usd'] as String?,
      usdFoil: json['usd_foil'] as String?,
      eur: json['eur'] as String?,
      eurFoil: json['eur_foil'] as String?,
    );

Map<String, dynamic> _$PricesToJson(Prices instance) => <String, dynamic>{
      'usd': instance.usd,
      'usd_foil': instance.usdFoil,
      'eur': instance.eur,
      'eur_foil': instance.eurFoil,
    };

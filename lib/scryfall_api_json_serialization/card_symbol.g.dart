// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_symbol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardSymbol _$CardSymbolFromJson(Map<String, dynamic> json) => CardSymbol(
      symbol: json['symbol'] as String,
      svgUri: json['svg_uri'] as String? ?? '',
    );

Map<String, dynamic> _$CardSymbolToJson(CardSymbol instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'svg_uri': instance.svgUri,
    };

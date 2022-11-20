// import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'card_symbol.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class CardSymbol {
  CardSymbol({
    required this.symbol,
    required this.svgUri,
  });
  String symbol;
  @JsonKey(defaultValue: '')
  String? svgUri;

  factory CardSymbol.fromJson(Map<String, dynamic> json) =>
      _$CardSymbolFromJson(json);

  Map<String, dynamic> toJson() => _$CardSymbolToJson(this);
}

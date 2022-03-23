// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_uris.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageLinks _$ImageLinksFromJson(Map<String, dynamic> json) => ImageLinks(
      png: json['png'] as String?,
      borderCrop: json['border_crop'] as String?,
      artCrop: json['art_crop'] as String?,
      large: json['large'] as String?,
      normal: json['normal'] as String?,
      small: json['small'] as String?,
    );

Map<String, dynamic> _$ImageLinksToJson(ImageLinks instance) =>
    <String, dynamic>{
      'png': instance.png,
      'border_crop': instance.borderCrop,
      'art_crop': instance.artCrop,
      'large': instance.large,
      'normal': instance.normal,
      'small': instance.small,
    };

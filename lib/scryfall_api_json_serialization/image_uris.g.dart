// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_uris.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageUris _$ImageUrisFromJson(Map<String, dynamic> json) => ImageUris(
      png: json['png'] as String?,
      borderCrop: json['border_crop'] as String?,
      artCrop: json['art_crop'] as String?,
      large: json['large'] as String?,
      normal: json['normal'] as String?,
      small: json['small'] as String?,
    );

Map<String, dynamic> _$ImageUrisToJson(ImageUris instance) => <String, dynamic>{
      'png': instance.png,
      'border_crop': instance.borderCrop,
      'art_crop': instance.artCrop,
      'large': instance.large,
      'normal': instance.normal,
      'small': instance.small,
    };

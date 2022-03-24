// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulkData _$BulkDataFromJson(Map<String, dynamic> json) => BulkData(
      id: json['id'] as String,
      uri: json['uri'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      downloadUri: json['download_uri'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      compressedSize: json['compressed_size'] as int,
      contentType: json['content_type'] as String,
      contentEncoding: json['content_encoding'] as String,
    );

Map<String, dynamic> _$BulkDataToJson(BulkData instance) => <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'download_uri': instance.downloadUri,
      'updated_at': instance.updatedAt.toIso8601String(),
      'compressed_size': instance.compressedSize,
      'content_type': instance.contentType,
      'content_encoding': instance.contentEncoding,
    };

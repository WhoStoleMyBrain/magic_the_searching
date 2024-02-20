import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'bulk_data.g.dart';

DateTime dateTimeFromJson(List<dynamic>? json) {
  return DateTime.parse(json?[0]);
}

Map<String, dynamic> dateTimeToJson(DateTime instance) {
  return {'dateTime': instance.toIso8601String()};
}

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable(fieldRename: FieldRename.snake)
class BulkData {
  //flutter pub run build_runner watch
  BulkData({
    required this.id,
    required this.uri,
    required this.type,
    required this.name,
    required this.description,
    required this.downloadUri,
    required this.updatedAt,
    required this.size,
    // required this.compressedSize,
    required this.contentType,
    required this.contentEncoding,

  });
  String id;
  String uri;
  String type;
  String name;
  String description;
  String downloadUri;
  // @JsonKey(
  //     fromJson: dateTimeFromJson,
  //     toJson: dateTimeToJson)
  DateTime updatedAt;
  int size;
  // int compressedSize;
  String contentType;
  String contentEncoding;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory BulkData.fromJson(Map<String, dynamic> json) =>
      _$BulkDataFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$BulkDataToJson(this);
}

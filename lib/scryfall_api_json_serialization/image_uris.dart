import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'image_uris.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class ImageLinks {
  //flutter pub run build_runner watch
  ImageLinks({
    // required this.image_uris,
    // required this.frontImage,
    // required this.backImage,
    required this.png,
    required this.borderCrop,
    required this.artCrop,
    required this.large,
    required this.normal,
    required this.small,
  });
  String? png;
  @JsonKey(name: 'border_crop')
  String? borderCrop;
  @JsonKey(name: 'art_crop')
  String? artCrop;
  String? large;
  String? normal;
  String? small;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory ImageLinks.fromJson(Map<String, dynamic> json) =>
      _$ImageLinksFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$ImageLinksToJson(this);
}

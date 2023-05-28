class MtGSet {
  final String code;
  final String name;
  final DateTime? releasedAt;
  final String iconSvgUri;

  MtGSet({
    required this.code,
    required this.name,
    this.releasedAt,
    required this.iconSvgUri,
  });
}

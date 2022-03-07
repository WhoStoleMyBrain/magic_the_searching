class CardData {
  String id;
  String name;
  String text;
  List<String> images;
  bool hasTwoSides;
  Map<String, dynamic> price;

  CardData({
    required this.id,
    required this.name,
    required this.text,
    required this.images,
    required this.hasTwoSides,
    required this.price,
  });
}
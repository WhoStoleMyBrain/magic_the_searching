import 'package:flutter/foundation.dart';

class ImageTakenProvider with ChangeNotifier {
  bool openModalSheet = false;
  String cardName;

  List<String> cardType;

  List<String> creatureType;

  String language;

  ImageTakenProvider(
      this.cardName, this.cardType, this.creatureType, this.language);
}

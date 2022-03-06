import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/card_data.dart';

class CardDataProvider with ChangeNotifier {
  List<CardData> _cards = [];

  List<CardData> get cards {
    return [..._cards];
  }

  CardData getCardById(String id) {
    return _cards.firstWhere((card) => card.id == id);
  }

  void setDummyData() {
    _cards = [
      CardData(
        id: '1',
        name: 'black lotus',
        text: 'Add 3 colored mana in any combination',
        image: 'assets/images/black_lotus.jpg',
      ),
      CardData(
        id: '2',
        name: 'tropical island',
        text: 'Add G or B. Play this ability as an interrupt',
        image: 'assets/images/tropical_island.jpg',
      ),
      CardData(
        id: '3',
        name: 'werebear',
        text: 'He exercises his right to bear arms',
        image: 'assets/images/werebear.jpg',
      ),
    ];
    notifyListeners();
  }
}

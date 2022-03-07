import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/card_data.dart';

class CardDataProvider with ChangeNotifier {
  List<CardData> _cards = [];

  List<CardData> get cards {
    return [..._cards];
  }

  set cards(List<CardData> queryData) {
    _cards = queryData;
    // print('Cards changed');
    // print(_cards);
    notifyListeners();
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
        images: ['assets/images/black_lotus.jpg'],
        hasTwoSides: false,
        price: {
          'tcg': '0.0',
          'tcg_foil': '0.0',
          'cardmarket': '0.0',
          'cardmarket_foil': '0.0',
        },
      ),
      CardData(

        id: '2',
        name: 'tropical island',
        text: 'Add G or B. Play this ability as an interrupt',
        images: ['assets/images/tropical_island.jpg'],
        hasTwoSides: false,
        price: {
          'tcg': '0.0',
          'tcg_foil': '0.0',
          'cardmarket': '0.0',
          'cardmarket_foil': '0.0',
        },
      ),
      CardData(
        id: '3',
        name: 'werebear',
        text: 'He exercises his right to bear arms',
        images: ['assets/images/werebear.jpg'],
        hasTwoSides: false,
        price: {
          'tcg': '0.0',
          'tcg_foil': '0.0',
          'cardmarket': '0.0',
          'cardmarket_foil': '0.0',
        },
      ),
    ];
    notifyListeners();
  }
}

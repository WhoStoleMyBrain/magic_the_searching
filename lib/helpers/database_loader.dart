import 'dart:convert';

import 'package:flutter/services.dart';

class DatabaseLoader {
  static String cardDatabasePath = 'assets/data/ScryfallDummyData.json';
  static List _items = [];

  static Future<List> readDataFromDBFile(String databasePath) async {
    try {
      final response = await rootBundle.loadString(databasePath);
      final data = await json.decode(response);
      _items = data;
      return _items;
    } catch (err) {
      print('error:' + err.toString());
      return [];
    }
  }

  static List<Map<String, dynamic>> cardDummyData = [
    {
      "object": "card",
      "id": "005a993c-5111-4364-9fba-75b3d94a8296",
      "oracle_id": "a3fb7228-e76b-4e96-a40e-20b5fed75685",
      "multiverse_ids": [891],
      "tcgplayer_id": 18305,
      "cardmarket_id": 5203,
      "name": "Mountain",
      "lang": "en",
      "released_at": "1993-12-01",
      "uri":
          "https://api.scryfall.com/cards/005a993c-5111-4364-9fba-75b3d94a8296",
      "scryfall_uri":
          "https://scryfall.com/card/2ed/298/mountain?utm_source=api",
      "layout": "normal",
      "highres_image": true,
      "image_status": "highres_scan",
      "image_uris": {
        "small":
            "https://c1.scryfall.com/file/scryfall-cards/small/front/0/0/005a993c-5111-4364-9fba-75b3d94a8296.jpg?1559591904",
        "normal":
            "https://c1.scryfall.com/file/scryfall-cards/normal/front/0/0/005a993c-5111-4364-9fba-75b3d94a8296.jpg?1559591904",
        "large":
            "https://c1.scryfall.com/file/scryfall-cards/large/front/0/0/005a993c-5111-4364-9fba-75b3d94a8296.jpg?1559591904",
        "png":
            "https://c1.scryfall.com/file/scryfall-cards/png/front/0/0/005a993c-5111-4364-9fba-75b3d94a8296.png?1559591904",
        "art_crop":
            "https://c1.scryfall.com/file/scryfall-cards/art_crop/front/0/0/005a993c-5111-4364-9fba-75b3d94a8296.jpg?1559591904",
        "border_crop":
            "https://c1.scryfall.com/file/scryfall-cards/border_crop/front/0/0/005a993c-5111-4364-9fba-75b3d94a8296.jpg?1559591904"
      },
      "mana_cost": "",
      "cmc": 0.0,
      "type_line": "Basic Land — Mountain",
      "oracle_text": "({T}: Add {R}.)",
      "colors": [],
      "color_identity": ["R"],
      "keywords": [],
      "produced_mana": ["R"],
      "legalities": {
        "standard": "legal",
        "future": "legal",
        "historic": "legal",
        "gladiator": "legal",
        "pioneer": "legal",
        "modern": "legal",
        "legacy": "legal",
        "pauper": "legal",
        "vintage": "legal",
        "penny": "legal",
        "commander": "legal",
        "brawl": "legal",
        "historicbrawl": "legal",
        "alchemy": "legal",
        "paupercommander": "legal",
        "duel": "legal",
        "oldschool": "legal",
        "premodern": "legal"
      },
      "games": ["paper"],
      "reserved": false,
      "foil": false,
      "nonfoil": true,
      "finishes": ["nonfoil"],
      "oversized": false,
      "promo": false,
      "reprint": true,
      "variation": false,
      "set_id": "cd7694b9-339c-405d-a991-14413d4f6d5c",
      "set": "2ed",
      "set_name": "Unlimited Edition",
      "set_type": "core",
      "set_uri":
          "https://api.scryfall.com/sets/cd7694b9-339c-405d-a991-14413d4f6d5c",
      "set_search_uri":
          "https://api.scryfall.com/cards/search?order=set\u0026q=e%3A2ed\u0026unique=prints",
      "scryfall_set_uri": "https://scryfall.com/sets/2ed?utm_source=api",
      "rulings_uri":
          "https://api.scryfall.com/cards/005a993c-5111-4364-9fba-75b3d94a8296/rulings",
      "prints_search_uri":
          "https://api.scryfall.com/cards/search?order=released\u0026q=oracleid%3Aa3fb7228-e76b-4e96-a40e-20b5fed75685\u0026unique=prints",
      "collector_number": "298",
      "digital": false,
      "rarity": "common",
      "card_back_id": "0aeebaf5-8c7d-4636-9e82-8c27447861f7",
      "artist": "Douglas Shuler",
      "artist_ids": ["a9ddb513-51c7-455c-ab8f-5b90aae9f75b"],
      "illustration_id": "995046ae-2f0d-4b43-a6e4-b4fb24859ed8",
      "border_color": "white",
      "frame": "1993",
      "full_art": false,
      "textless": false,
      "booster": true,
      "story_spotlight": false,
      "prices": {
        "usd": "2.76",
        "usd_foil": null,
        "usd_etched": null,
        "eur": "5.11",
        "eur_foil": null,
        "tix": null
      },
      "related_uris": {
        "gatherer":
            "https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=891",
        "tcgplayer_infinite_articles":
            "https://infinite.tcgplayer.com/search?contentMode=article\u0026game=magic\u0026partner=scryfall\u0026q=Mountain\u0026utm_campaign=affiliate\u0026utm_medium=api\u0026utm_source=scryfall",
        "tcgplayer_infinite_decks":
            "https://infinite.tcgplayer.com/search?contentMode=deck\u0026game=magic\u0026partner=scryfall\u0026q=Mountain\u0026utm_campaign=affiliate\u0026utm_medium=api\u0026utm_source=scryfall",
        "edhrec": "https://edhrec.com/route/?cc=Mountain",
        "mtgtop8":
            "https://mtgtop8.com/search?MD_check=1\u0026SB_check=1\u0026cards=Mountain"
      }
    },
    {
      "object": "card",
      "id": "005ad65e-cf0b-48e9-a314-2ebba5a1400c",
      "oracle_id": "ec439630-e18b-45f6-8034-2ecbea27772f",
      "multiverse_ids": [433115],
      "tcgplayer_id": 139996,
      "cardmarket_id": 300497,
      "name": "Nin, the Pain Artist",
      "lang": "en",
      "released_at": "2017-08-25",
      "uri":
          "https://api.scryfall.com/cards/005ad65e-cf0b-48e9-a314-2ebba5a1400c",
      "scryfall_uri":
          "https://scryfall.com/card/c17/183/nin-the-pain-artist?utm_source=api",
      "layout": "normal",
      "highres_image": true,
      "image_status": "highres_scan",
      "image_uris": {
        "small":
            "https://c1.scryfall.com/file/scryfall-cards/small/front/0/0/005ad65e-cf0b-48e9-a314-2ebba5a1400c.jpg?1562598065",
        "normal":
            "https://c1.scryfall.com/file/scryfall-cards/normal/front/0/0/005ad65e-cf0b-48e9-a314-2ebba5a1400c.jpg?1562598065",
        "large":
            "https://c1.scryfall.com/file/scryfall-cards/large/front/0/0/005ad65e-cf0b-48e9-a314-2ebba5a1400c.jpg?1562598065",
        "png":
            "https://c1.scryfall.com/file/scryfall-cards/png/front/0/0/005ad65e-cf0b-48e9-a314-2ebba5a1400c.png?1562598065",
        "art_crop":
            "https://c1.scryfall.com/file/scryfall-cards/art_crop/front/0/0/005ad65e-cf0b-48e9-a314-2ebba5a1400c.jpg?1562598065",
        "border_crop":
            "https://c1.scryfall.com/file/scryfall-cards/border_crop/front/0/0/005ad65e-cf0b-48e9-a314-2ebba5a1400c.jpg?1562598065"
      },
      "mana_cost": "{U}{R}",
      "cmc": 2.0,
      "type_line": "Legendary Creature — Vedalken Wizard",
      "oracle_text":
          "{X}{U}{R}, {T}: Nin, the Pain Artist deals X damage to target creature. That creature's controller draws X cards.",
      "power": "1",
      "toughness": "1",
      "colors": ["R", "U"],
      "color_identity": ["R", "U"],
      "keywords": [],
      "legalities": {
        "standard": "not_legal",
        "future": "not_legal",
        "historic": "not_legal",
        "gladiator": "not_legal",
        "pioneer": "not_legal",
        "modern": "not_legal",
        "legacy": "legal",
        "pauper": "not_legal",
        "vintage": "legal",
        "penny": "not_legal",
        "commander": "legal",
        "brawl": "not_legal",
        "historicbrawl": "not_legal",
        "alchemy": "not_legal",
        "paupercommander": "not_legal",
        "duel": "legal",
        "oldschool": "not_legal",
        "premodern": "not_legal"
      },
      "games": ["paper"],
      "reserved": false,
      "foil": false,
      "nonfoil": true,
      "finishes": ["nonfoil"],
      "oversized": false,
      "promo": false,
      "reprint": true,
      "variation": false,
      "set_id": "5caec427-0c78-4c37-b4ec-30f7e0ba9abf",
      "set": "c17",
      "set_name": "Commander 2017",
      "set_type": "commander",
      "set_uri":
          "https://api.scryfall.com/sets/5caec427-0c78-4c37-b4ec-30f7e0ba9abf",
      "set_search_uri":
          "https://api.scryfall.com/cards/search?order=set\u0026q=e%3Ac17\u0026unique=prints",
      "scryfall_set_uri": "https://scryfall.com/sets/c17?utm_source=api",
      "rulings_uri":
          "https://api.scryfall.com/cards/005ad65e-cf0b-48e9-a314-2ebba5a1400c/rulings",
      "prints_search_uri":
          "https://api.scryfall.com/cards/search?order=released\u0026q=oracleid%3Aec439630-e18b-45f6-8034-2ecbea27772f\u0026unique=prints",
      "collector_number": "183",
      "digital": false,
      "rarity": "rare",
      "flavor_text":
          "\"Your body is a delicate instrument that tells me truths. These devices help me 'tune' that instrument.\"",
      "card_back_id": "0aeebaf5-8c7d-4636-9e82-8c27447861f7",
      "artist": "Brad Rigney",
      "artist_ids": ["f17194b9-10e9-44ea-9b65-6812ab398624"],
      "illustration_id": "82821742-928a-4084-b0f0-25cb081d69dc",
      "border_color": "black",
      "frame": "2015",
      "security_stamp": "oval",
      "full_art": false,
      "textless": false,
      "booster": false,
      "story_spotlight": false,
      "edhrec_rank": 4947,
      "prices": {
        "usd": "0.48",
        "usd_foil": null,
        "usd_etched": null,
        "eur": "0.20",
        "eur_foil": null,
        "tix": null
      },
      "related_uris": {
        "gatherer":
            "https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=433115",
        "tcgplayer_infinite_articles":
            "https://infinite.tcgplayer.com/search?contentMode=article\u0026game=magic\u0026partner=scryfall\u0026q=Nin%2C+the+Pain+Artist\u0026utm_campaign=affiliate\u0026utm_medium=api\u0026utm_source=scryfall",
        "tcgplayer_infinite_decks":
            "https://infinite.tcgplayer.com/search?contentMode=deck\u0026game=magic\u0026partner=scryfall\u0026q=Nin%2C+the+Pain+Artist\u0026utm_campaign=affiliate\u0026utm_medium=api\u0026utm_source=scryfall",
        "edhrec": "https://edhrec.com/route/?cc=Nin%2C+the+Pain+Artist",
        "mtgtop8":
            "https://mtgtop8.com/search?MD_check=1\u0026SB_check=1\u0026cards=Nin%2C+the+Pain+Artist"
      }
    },
    {
      "object": "card",
      "id": "005ae9a2-b235-49ee-ae54-6875e087f43d",
      "oracle_id": "e94297af-1236-4c9a-860f-2ee6a0d12e5e",
      "multiverse_ids": [380254],
      "mtgo_id": 52427,
      "mtgo_foil_id": 52428,
      "tcgplayer_id": 79924,
      "cardmarket_id": 266335,
      "name": "Corpse Traders",
      "lang": "en",
      "released_at": "2014-03-14",
      "uri":
          "https://api.scryfall.com/cards/005ae9a2-b235-49ee-ae54-6875e087f43d",
      "scryfall_uri":
          "https://scryfall.com/card/ddm/58/corpse-traders?utm_source=api",
      "layout": "normal",
      "highres_image": true,
      "image_status": "highres_scan",
      "image_uris": {
        "small":
            "https://c1.scryfall.com/file/scryfall-cards/small/front/0/0/005ae9a2-b235-49ee-ae54-6875e087f43d.jpg?1592754744",
        "normal":
            "https://c1.scryfall.com/file/scryfall-cards/normal/front/0/0/005ae9a2-b235-49ee-ae54-6875e087f43d.jpg?1592754744",
        "large":
            "https://c1.scryfall.com/file/scryfall-cards/large/front/0/0/005ae9a2-b235-49ee-ae54-6875e087f43d.jpg?1592754744",
        "png":
            "https://c1.scryfall.com/file/scryfall-cards/png/front/0/0/005ae9a2-b235-49ee-ae54-6875e087f43d.png?1592754744",
        "art_crop":
            "https://c1.scryfall.com/file/scryfall-cards/art_crop/front/0/0/005ae9a2-b235-49ee-ae54-6875e087f43d.jpg?1592754744",
        "border_crop":
            "https://c1.scryfall.com/file/scryfall-cards/border_crop/front/0/0/005ae9a2-b235-49ee-ae54-6875e087f43d.jpg?1592754744"
      },
      "mana_cost": "{3}{B}",
      "cmc": 4.0,
      "type_line": "Creature — Human Rogue",
      "oracle_text":
          "{2}{B}, Sacrifice a creature: Target opponent reveals their hand. You choose a card from it. That player discards that card. Activate only as a sorcery.",
      "power": "3",
      "toughness": "3",
      "colors": ["B"],
      "color_identity": ["B"],
      "keywords": [],
      "legalities": {
        "standard": "not_legal",
        "future": "not_legal",
        "historic": "legal",
        "gladiator": "legal",
        "pioneer": "not_legal",
        "modern": "legal",
        "legacy": "legal",
        "pauper": "not_legal",
        "vintage": "legal",
        "penny": "legal",
        "commander": "legal",
        "brawl": "not_legal",
        "historicbrawl": "legal",
        "alchemy": "not_legal",
        "paupercommander": "restricted",
        "duel": "legal",
        "oldschool": "not_legal",
        "premodern": "not_legal"
      },
      "games": ["paper", "mtgo"],
      "reserved": false,
      "foil": false,
      "nonfoil": true,
      "finishes": ["nonfoil"],
      "oversized": false,
      "promo": false,
      "reprint": true,
      "variation": false,
      "set_id": "a80b4ba1-7485-4c16-b745-eeea904863c3",
      "set": "ddm",
      "set_name": "Duel Decks: Jace vs. Vraska",
      "set_type": "duel_deck",
      "set_uri":
          "https://api.scryfall.com/sets/a80b4ba1-7485-4c16-b745-eeea904863c3",
      "set_search_uri":
          "https://api.scryfall.com/cards/search?order=set\u0026q=e%3Addm\u0026unique=prints",
      "scryfall_set_uri": "https://scryfall.com/sets/ddm?utm_source=api",
      "rulings_uri":
          "https://api.scryfall.com/cards/005ae9a2-b235-49ee-ae54-6875e087f43d/rulings",
      "prints_search_uri":
          "https://api.scryfall.com/cards/search?order=released\u0026q=oracleid%3Ae94297af-1236-4c9a-860f-2ee6a0d12e5e\u0026unique=prints",
      "collector_number": "58",
      "digital": false,
      "rarity": "uncommon",
      "flavor_text": "Those without breath can't complain.",
      "card_back_id": "0aeebaf5-8c7d-4636-9e82-8c27447861f7",
      "artist": "Kev Walker",
      "artist_ids": ["f366a0ee-a0cd-466d-ba6a-90058c7a31a6"],
      "illustration_id": "6969a972-addd-4589-a2ad-2e39c1db5402",
      "border_color": "black",
      "frame": "2003",
      "full_art": false,
      "textless": false,
      "booster": false,
      "story_spotlight": false,
      "edhrec_rank": 15877,
      "prices": {
        "usd": "0.10",
        "usd_foil": null,
        "usd_etched": null,
        "eur": "0.06",
        "eur_foil": null,
        "tix": "0.05"
      },
      "related_uris": {
        "gatherer":
            "https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=380254",
        "tcgplayer_infinite_articles":
            "https://infinite.tcgplayer.com/search?contentMode=article\u0026game=magic\u0026partner=scryfall\u0026q=Corpse+Traders\u0026utm_campaign=affiliate\u0026utm_medium=api\u0026utm_source=scryfall",
        "tcgplayer_infinite_decks":
            "https://infinite.tcgplayer.com/search?contentMode=deck\u0026game=magic\u0026partner=scryfall\u0026q=Corpse+Traders\u0026utm_campaign=affiliate\u0026utm_medium=api\u0026utm_source=scryfall",
        "edhrec": "https://edhrec.com/route/?cc=Corpse+Traders",
        "mtgtop8":
            "https://mtgtop8.com/search?MD_check=1\u0026SB_check=1\u0026cards=Corpse+Traders"
      }
    },
  ];
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_the_searching/providers/card_data_provider.dart';

import '../models/card_data.dart';

class CardDetailScreen extends StatelessWidget {
  static const routeName = '/card-detail';

  const CardDetailScreen({Key? key}) : super(key: key);

  // final CardData cardData;

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String;
    final cardData =
        Provider.of<CardDataProvider>(context, listen: false).getCardById(id);
    final mediaQuery = MediaQuery.of(context);
    // const double fontSize = 20;
    const TextStyle textStyle = TextStyle(fontSize: 24,);
    return Scaffold(
        appBar: AppBar(
          title: Text(cardData.name),
        ),
        body: InkWell(
          onTap: () {
            // cardTapped(context, cardData.id);
          },
          child: SizedBox(
            height: mediaQuery.size.height,
            child: Card(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CardImageDisplay(
                        cardData: cardData, mediaQuery: mediaQuery),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Expanded(child: Text('Normal', style: textStyle,)),
                              Expanded(child: Text('Foil', style: textStyle,)),
                            ],
                          ),
                          const Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child:
                                      Text('TCG:  \$${cardData.price['tcg']}', style: textStyle,)),
                              // Expanded(child: Container()),
                              Expanded(
                                  child: Text(
                                      'TCG:  \$${cardData.price['tcg_foil']}', style: textStyle,)),
                            ],
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                      'CDM: €${cardData.price['cardmarket']}', style: textStyle,)),
                              Expanded(
                                  child: Text(
                                      'CDM: €${cardData.price['cardmarket_foil']}', style: textStyle,)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class CardImageDisplay extends StatefulWidget {
  const CardImageDisplay({
    Key? key,
    required this.cardData,
    required this.mediaQuery,
  }) : super(key: key);

  final CardData cardData;
  final MediaQueryData mediaQuery;

  @override
  State<CardImageDisplay> createState() => _CardImageDisplayState();
}

class _CardImageDisplayState extends State<CardImageDisplay> {
  int _side = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      // alignment: Alignment.center ,
      children: [
        widget.cardData.images[_side].contains('http')
            ? Image.network(
                widget.cardData.images[_side],
                fit: BoxFit.cover,
                width: (widget.mediaQuery.size.width -
                    widget.mediaQuery.padding.horizontal),
                height: (widget.mediaQuery.size.height * 2 / 3),
              )
            : Image(image: AssetImage(widget.cardData.images[_side])),
        if (widget.cardData.hasTwoSides)
          Positioned(
            left: (widget.mediaQuery.size.width -
                        widget.mediaQuery.padding.horizontal) /
                    2 -
                50,
            top: (widget.mediaQuery.size.height * 2 / 3) - 70 - 10,
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _side == 0 ? _side = 1 : _side = 0;
                });
              },
              child: const Icon(
                Icons.compare_arrows,
                size: 50,
                color: Colors.black87,
              ),
              height: 70,
              shape: const CircleBorder(),
              color: const Color.fromRGBO(128, 128, 128, 0.5),
            ),
          ),
      ],
    );
  }
}

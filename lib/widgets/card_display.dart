import 'package:flutter/material.dart';
import '../models/card_data.dart';

class CardDisplay extends StatelessWidget {
  final CardData cardData;
  final Function cardTapped;

  const CardDisplay(
      {Key? key, required this.cardData, required this.cardTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return InkWell(
      onTap: () {
        cardTapped(context, cardData.id);
      },
      child: SizedBox(
        height: mediaQuery.size.height,
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  // alignment: Alignment.center ,
                  children: [
                    cardData.images[0].contains('http')
                        ? Image.network(
                            cardData.images[0],
                            fit: BoxFit.cover,
                            width: (mediaQuery.size.width -
                                    mediaQuery.padding.horizontal) /
                                2,
                            height: (mediaQuery.size.height / 3),
                          )
                        : Image(image: AssetImage(cardData.images[0])),
                    if (cardData.hasTwoSides)
                      Positioned(
                        left: 50,
                        child: MaterialButton(
                          onPressed: () {},
                          child: const Icon(Icons.compare_arrows, size: 35, color: Colors.black87,),
                          height: 50,
                          shape: const CircleBorder(),
                          color: const Color.fromRGBO(128, 128, 128, 0.5),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Normal'),
                          Text('Foil'),
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
                              child: Text('TCG:  \$${cardData.price['tcg']}')),
                          // Expanded(child: Container()),
                          Expanded(
                              child: Text(
                                  'TCG:  \$${cardData.price['tcg_foil']}')),
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
                                  'CDM: €${cardData.price['cardmarket']}')),
                          Expanded(
                              child: Text(
                                  'CDM: €${cardData.price['cardmarket_foil']}')),
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
    );
  }
}

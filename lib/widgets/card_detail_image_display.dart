import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:magic_the_searching/helpers/card_symbol_helper.dart';
import 'package:magic_the_searching/providers/card_symbol_provider.dart';
import 'package:provider/provider.dart';

import '../scryfall_api_json_serialization/card_info.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/settings.dart';
import '../scryfall_api_json_serialization/image_uris.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardDetailImageDisplay extends StatefulWidget {
  const CardDetailImageDisplay({
    Key? key,
    required this.cardInfo,
    required this.mediaQuery,
  }) : super(key: key);

  final CardInfo cardInfo;
  final MediaQueryData mediaQuery;

  @override
  State<CardDetailImageDisplay> createState() => _CardDetailImageDisplayState();
}

class _CardDetailImageDisplayState extends State<CardDetailImageDisplay> {
  int _side = 0;
  Map<String, SvgPicture> symbolImages = {};
  late Image? _networkImageStream;
  late bool _hasInternetConnection = true;
  late Stream<FileResponse> fileStream;

  Stream<FileResponse>? getLocalImage(Settings settings) {
    if (settings.useImagesFromNet) {
      List<ImageUris?>? localImages = (widget.cardInfo.hasTwoSides &&
              (widget.cardInfo.imageUris?.normal == null))
          ? widget.cardInfo.cardFaces
          : [widget.cardInfo.imageUris];
      fileStream = DefaultCacheManager().getImageFile(
          localImages?[_side]?.normal ?? (localImages?[_side]?.small ?? ''));
      _hasInternetConnection = true;
      return fileStream;
    }
    return null;
  }

  List<Widget> cardNameAndManaSymbol() {
    List<String> cardSymbols =
        CardSymbolHelper.getSymbolsOfText(widget.cardInfo.manaCost ?? '');

    return [
      SizedBox(
        width: widget.mediaQuery.size.width * 0.9,
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: cardSymbols.length > 9
                  ? widget.mediaQuery.size.width * 0.25
                  : widget.mediaQuery.size.width *
                      (0.85 - 0.066 * cardSymbols.length),
              child: AutoSizeText(
                // '',
                overflow: TextOverflow.ellipsis,
                widget.cardInfo.name ??
                    'No name found for this card.', // https://pub.dev/packages/auto_size_text for auto title resize!
                style: const TextStyle(
                  fontSize: 24,
                ),
                maxLines: 1,
              ),
            ),
            cardSymbols.isNotEmpty
                ? Row(
                    children: [
                      ...cardSymbols.map((e) => SvgPicture.asset(
                            e,
                            width: 24,
                            height: 24,
                          ))
                    ],
                  )
                : Text(
                    widget.cardInfo.manaCost ?? '',
                    style: const TextStyle(fontSize: 24),
                  ),
          ],
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  List<Widget> cardTypeLine() {
    return [
      Text(widget.cardInfo.typeLine ?? '',
          style: const TextStyle(fontSize: 16)),
    ];
  }

  Widget oracleText() {
    var richText = buildRichTextSpan(widget.cardInfo.oracleText ?? '');
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          child: richText,
        ),
      ),
    );
  }

  List<Widget> flavorText() {
    return [
      Text(
        widget.cardInfo.flavorText ?? '',
        style: const TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  Widget loyaltyColumn() {
    return Column(
      children: [
        ...widget.cardInfo.loyalty?.split('PLACEHOLDER_SPLIT_TEXT').map((e) {
              // print(e);
              return e == 'null'
                  ? const SizedBox.shrink()
                  : Stack(alignment: AlignmentDirectional.center, children: [
                      SvgPicture.asset(
                        'assets/images/Loyalty.svg',
                        width: 24,
                        height: 24,
                      ),
                      Center(
                        child: Text(
                          e,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ]);
            }).toList() ??
            [],
      ],
    );
  }

  Widget powerAndToughnessColumn() {
    // List listItems = [];
    // widget.cardInfo.power?.split('PLACEHOLDER_SPLIT_TEXT').forEach(
    return Column(
      children: [
        ...widget.cardInfo.power
                ?.split('PLACEHOLDER_SPLIT_TEXT')
                .asMap()
                .entries
                .map((e) {
              String toughness = widget.cardInfo.toughness
                      ?.split('PLACEHOLDER_SPLIT_TEXT')[e.key] ??
                  "-";
              // print(toughness);
              // print(e);
              return (e.value == 'null' || toughness == 'null')
                  ? const SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Card(
                          elevation: 1,
                          color: const Color.fromRGBO(229, 230, 230, 1.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Text(
                              '${e.value}/$toughness',
                              style: const TextStyle(
                                fontSize: 23,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
            }).toList() ??
            [],
      ],
    );
  }

  List<Widget> setNameAndPowerAndToughness() {
    // print(widget.cardInfo.power);
    // print(widget.cardInfo.toughness);
    // print(widget.cardInfo.loyalty);
    return [
      SizedBox(
        width: widget.mediaQuery.size.width * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...setName(),
            widget.cardInfo.loyalty != null
                ? loyaltyColumn()
                : powerAndToughnessColumn(),
          ],
        ),
      ),
      (widget.cardInfo.power == null && widget.cardInfo.toughness == null)
          ? const SizedBox.shrink()
          : const SizedBox(
              height: 10,
            ),
    ];
  }

  List<dynamic> textSpanWidgets(String text) {
    List<String> splittedText = text.split(RegExp(r'[{}]'));
    splittedText.removeWhere((element) {
      return element == '' || element == ' ';
    });
    var finalSpans = [];
    for (var tmp in splittedText) {
      tmp.contains('PLACEHOLDER_SPLIT_TEXT')
          ? finalSpans.addAll([
              TextSpan(
                  text: tmp.split('PLACEHOLDER_SPLIT_TEXT').first,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
              const WidgetSpan(
                  child: Divider(
                indent: 30,
                endIndent: 30,
                color: Colors.black,
                thickness: 1.5,
              )),
              TextSpan(
                  text: tmp.split('PLACEHOLDER_SPLIT_TEXT').last,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            ])
          : finalSpans.add(
              symbolImages.keys
                      .contains(CardSymbolHelper.symbolToAssetPath(tmp))
                  ? WidgetSpan(
                      alignment: ui.PlaceholderAlignment.middle,
                      child: SvgPicture.asset(
                        CardSymbolHelper.symbolToAssetPath(tmp),
                        height: 16,
                        width: 16,
                      ),
                    )
                  : TextSpan(
                      text: tmp,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black)),
            );
    }
    return finalSpans;
  }

  Widget buildRichTextSpan(String text) {
    return RichText(
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(
        children: [...textSpanWidgets(text)],
      ),
    );
  }

  double _getSetNameWidth() {
    return widget.mediaQuery.size.width *
        (0.7 -
            0.1 *
                (widget.cardInfo.power?.split('PLACEHOLDER_SPLIT_TEXT').first ==
                        null
                    ? widget.cardInfo.power
                            ?.split('PLACEHOLDER_SPLIT_TEXT')
                            .first
                            .length ??
                        0
                    : 0) -
            0.1 *
                (widget.cardInfo.toughness
                            ?.split('PLACEHOLDER_SPLIT_TEXT')
                            .first ==
                        null
                    ? widget.cardInfo.toughness
                            ?.split('PLACEHOLDER_SPLIT_TEXT')
                            .first
                            .length ??
                        0
                    : 0));
  }

  List<Widget> setName() {
    // print('Here we go!');
    // print(widget.cardInfo.power?.split('PLACEHOLDER_SPLIT_TEXT').first);
    return [
      SizedBox(
        width: _getSetNameWidth(),
        height: 24,
        child: AutoSizeText(
          'Set: ${widget.cardInfo.setName ?? 'Unknown Set'}',
          style: const TextStyle(
            fontSize: 16,
          ),
          maxLines: 1,
        ),
      ),
    ];
  }

  Widget cardText() {
    // print(widget.mediaQuery.size);
    // print((widget.mediaQuery.size.height - widget.mediaQuery.padding.top - 30) -
    // 100 -
    // 32 -
    // 16 -
    // 32);
    return Card(
        child: Container(
      height:
          (widget.mediaQuery.size.height - widget.mediaQuery.padding.top - 30) -
              100 -
              32 -
              16 -
              32,
      // width: widget.mediaQuery.size.width,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...cardNameAndManaSymbol(),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          ...cardTypeLine(),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          const SizedBox(
            height: 4,
          ),
          oracleText(),
          ...flavorText(),
          ...setNameAndPowerAndToughness(),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: true);
    final CardSymbolProvider cardSymbolProvider =
        Provider.of<CardSymbolProvider>(context, listen: true);
    symbolImages = cardSymbolProvider.symbolImages;
    return StreamBuilder<FileResponse>(
      stream: getLocalImage(settings),
      builder: (context, snapshot) {
        if (!(snapshot.hasError) &&
            (snapshot.hasData || snapshot.data is DownloadProgress) &&
            settings.useImagesFromNet) {
          FileInfo fileInfo = snapshot.data as FileInfo;
          _networkImageStream = Image.file(
            File(
              fileInfo.file.path,
            ),
            fit: BoxFit.cover,
          );
        }
        if (snapshot.hasError) {
          _networkImageStream = null;
          _hasInternetConnection = false;
        }
        return Stack(
          children: [
            (snapshot.connectionState == ConnectionState.done ||
                    !settings.useImagesFromNet)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: (_hasInternetConnection && settings.useImagesFromNet)
                        ? _networkImageStream
                        : cardText(),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            if (widget.cardInfo.hasTwoSides &&
                (widget.cardInfo.imageUris?.normal == null) &&
                settings.useImagesFromNet)
              getFlipButton(settings),
          ],
        );
      },
    );
  }

  Positioned getFlipButton(Settings settings) {
    return Positioned(
      left: (widget.mediaQuery.size.width -
                  widget.mediaQuery.padding.horizontal) /
              2 -
          50,
      top: (widget.mediaQuery.size.height * 2 / 3) - 70 - 10,
      child: MaterialButton(
        onPressed: () {
          setState(() {
            getLocalImage(settings);
            _side == 0 ? _side = 1 : _side = 0;
          });
        },
        height: 70,
        shape: const CircleBorder(),
        color: const Color.fromRGBO(128, 128, 128, 0.5),
        child: const Icon(
          Icons.compare_arrows,
          size: 50,
          color: Colors.black87,
        ),
      ),
    );
  }
}

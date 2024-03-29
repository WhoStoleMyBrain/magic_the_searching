import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../helpers/card_text_display_helper.dart';
import '../helpers/card_symbol_helper.dart';
import '../helpers/constants.dart';
import '../providers/card_symbol_provider.dart';
import '../providers/settings.dart';
import '../scryfall_api_json_serialization/image_uris.dart';
import '../scryfall_api_json_serialization/card_info.dart';

class CardImageDisplay extends StatefulWidget {
  const CardImageDisplay({
    super.key,
    required this.cardInfo,
    required this.mediaQuery,
  });

  final CardInfo cardInfo;
  final MediaQueryData mediaQuery;
  static bool pictureLoaded = false;

  @override
  State<CardImageDisplay> createState() => _CardImageDisplayState();
}

class _CardImageDisplayState extends State<CardImageDisplay> {
  int _side = 0;
  late Image? _networkImageStream;
  bool _hasInternetConnection = true;
  late Stream<FileResponse> fileStream;
  late Settings settings;
  Map<String, SvgPicture> symbolImages = {};

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

  double _getContainerHeight() {
    //TODO Rework this! I would LOVE to have a more dynamic approach
    return (widget.mediaQuery.size.height -
                2 * widget.mediaQuery.padding.vertical -
                2 * widget.mediaQuery.viewInsets.top) /
            2 -
        10 -
        90 -
        8 -
        10 -
        20;
  }

  double _getContainerWidth() {
    return (widget.mediaQuery.size.width -
                2 * widget.mediaQuery.padding.horizontal) /
            2 -
        24;
  }

  String getCardNameText() {
    if (settings.language != Languages.en &&
        widget.cardInfo.printedName != null) {
      return widget.cardInfo.printedName ?? 'No name found for this card.';
    } else {
      return widget.cardInfo.name ?? 'No name found for this card.';
    }
  }

  List<Widget> cardNameAndManaSymbol() {
    List<String> cardSymbols =
        CardSymbolHelper.getSymbolsOfText(widget.cardInfo.manaCost ?? '');
    return [
      Center(
        child: Text(
          getCardNameText(),
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      const SizedBox(
        height: 4,
      ),
      cardSymbols.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...cardSymbols.map((e) => SvgPicture.asset(
                      e,
                      width: 14,
                      height: 14,
                    ))
              ],
            )
          : Text(
              widget.cardInfo.manaCost ?? '',
              style: const TextStyle(fontSize: 24),
            ),
    ];
  }

  List<Widget> cardTypeLine() {
    return [
      Text(getCardTypeText(), style: const TextStyle(fontSize: 12)),
    ];
  }

  String getCardTypeText() {
    if (settings.language != Languages.en &&
        widget.cardInfo.printedTypeLine != null) {
      return widget.cardInfo.printedTypeLine ?? '';
    } else {
      return widget.cardInfo.typeLine ?? '';
    }
  }

  Widget buildRichTextSpan(String text) {
    return RichText(
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(
        children: [
          ...CardTextDisplayHelper.textSpanWidgetsFromText(
              text, symbolImages, 12)
        ],
      ),
    );
  }

  String getTextToDisplay() {
    if (settings.language != Languages.en &&
        widget.cardInfo.printedText != null) {
      return widget.cardInfo.printedText ?? '';
    } else {
      return widget.cardInfo.oracleText ?? '';
    }
  }

  Widget oracleText() {
    var richText = buildRichTextSpan(getTextToDisplay());
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          child: richText,
        ),
      ),
    );
  }

  List<Widget> powerAndToughness() {
    bool placeholderInLoyalty =
        widget.cardInfo.loyalty?.contains(Constants.placeholderSplitText) ??
            false;
    bool placeholderInPower =
        widget.cardInfo.power?.contains(Constants.placeholderSplitText) ??
            false;
    bool placeholderInToughness =
        widget.cardInfo.toughness?.contains(Constants.placeholderSplitText) ??
            false;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (widget.cardInfo.loyalty != null || placeholderInLoyalty)
              ? CardTextDisplayHelper.getLoyaltyDisplay(
                  widget.cardInfo.loyalty, 16)
              : (widget.cardInfo.power == null &&
                          widget.cardInfo.toughness == null ||
                      (placeholderInPower || placeholderInToughness))
                  ? const SizedBox.shrink()
                  : Text(
                      '${widget.cardInfo.power ?? "-"}/${widget.cardInfo.toughness ?? "-"}',
                      style: const TextStyle(fontSize: 12),
                    ),
        ],
      ),
      (widget.cardInfo.power == null && widget.cardInfo.toughness == null)
          ? const SizedBox.shrink()
          : const SizedBox(
              height: 4,
            ),
    ];
  }

  List<Widget> setName() {
    return [
      Text(
        'Set: ${widget.cardInfo.setName ?? 'Unknown Set'}',
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    ];
  }

  Widget cardText() {
    return Container(
      height: _getContainerHeight(),
      width: _getContainerWidth(),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ...cardNameAndManaSymbol(),
          const Divider(
            thickness: 0.5,
            color: Colors.black,
          ),
          ...cardTypeLine(),
          const Divider(
            thickness: 0.5,
            color: Colors.black,
          ),
          oracleText(),
          ...powerAndToughness(),
          ...setName(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    settings = Provider.of<Settings>(context, listen: true);
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
        return (snapshot.connectionState == ConnectionState.done ||
                !settings.useImagesFromNet)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (_hasInternetConnection && settings.useImagesFromNet)
                    // ? null
                    ? Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(24.0),
                              child: _networkImageStream),
                          if (widget.cardInfo.hasTwoSides &&
                              (widget.cardInfo.imageUris?.normal == null) &&
                              settings.useImagesFromNet)
                            Positioned(
                              left: (widget.mediaQuery.size.width) / 2 - 16,
                              bottom: 32,
                              width: 128,
                              height: 128,
                              child: MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    CardImageDisplay.pictureLoaded = false;
                                    getLocalImage(settings);
                                    _side == 0 ? _side = 1 : _side = 0;
                                  });
                                },
                                height: 64,
                                shape: const CircleBorder(),
                                color: const Color.fromRGBO(128, 128, 128, 0.5),
                                child: const Icon(
                                  Icons.compare_arrows,
                                  size: 92,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                        ],
                      )
                    : cardText(),
              )
            : SizedBox(
                width: (widget.mediaQuery.size.width -
                        widget.mediaQuery.padding.horizontal) /
                    2,
                height: (widget.mediaQuery.size.height / 4),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }
}

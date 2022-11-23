import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../helpers/card_symbol_helper.dart';
import '../providers/card_symbol_provider.dart';
import '../scryfall_api_json_serialization/card_info.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/settings.dart';
import '../scryfall_api_json_serialization/image_uris.dart';

class CardImageDisplay extends StatefulWidget {
  const CardImageDisplay({
    Key? key,
    required this.cardInfo,
    required this.mediaQuery,
  }) : super(key: key);

  final CardInfo cardInfo;
  final MediaQueryData mediaQuery;
  static bool pictureLoaded = false;

  @override
  State<CardImageDisplay> createState() => _CardImageDisplayState();
}

class _CardImageDisplayState extends State<CardImageDisplay> {
  int _side = 0;
  late Image? _networkImageStream;
  late bool _hasInternetConnection = true;
  late Stream<FileResponse> fileStream;
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
    return (widget.mediaQuery.size.height -
                2 * widget.mediaQuery.padding.vertical -
                2 * widget.mediaQuery.viewInsets.top) /
            2 -
        10 -
        90 -
        8 -
        10;
  }

  List<Widget> cardNameAndManaSymbol() {
    List<String> cardSymbols =
        CardSymbolHelper.getSymbolsOfText(widget.cardInfo.manaCost ?? '');
    return [
      Center(
        child: Text(
          widget.cardInfo.name ?? 'No name found for this card.',
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
      Text(widget.cardInfo.typeLine ?? '',
          style: const TextStyle(fontSize: 12)),
      // const SizedBox(
      //   height: 10,
      // ),
    ];
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

  List<dynamic> textSpanWidgets(String text) {
    // text = text.replaceFirst(r'PLACEHOLDER_SPLIT_TEXT', '\n');
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
                  style: const TextStyle(fontSize: 12, color: Colors.black)),
              const WidgetSpan(
                  child: Divider(
                endIndent: 20,
                indent: 20,
                color: Colors.black,
                thickness: 1,
              )),
              TextSpan(
                  text: tmp.split('PLACEHOLDER_SPLIT_TEXT').last,
                  style: const TextStyle(fontSize: 12, color: Colors.black)),
            ])
          : finalSpans.add(
              symbolImages.keys
                      .contains(CardSymbolHelper.symbolToAssetPath(tmp))
                  ? WidgetSpan(
                      alignment: ui.PlaceholderAlignment.middle,
                      child: SvgPicture.asset(
                        CardSymbolHelper.symbolToAssetPath(tmp),
                        height: 12,
                        width: 12,
                      ),
                    )
                  : TextSpan(
                      text: tmp,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black)),
            );
    }
    return finalSpans;
  }

  List<Widget> oracleText() {
    var richText = buildRichTextSpan(widget.cardInfo.oracleText ?? '');
    return [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...cardTypeLine(),
              const Divider(
                thickness: 0.5,
                color: Colors.black,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: richText,
              )
              // Text(
              //   widget.cardInfo.oracleText ?? 'No Oracle text found',
              //   style: const TextStyle(fontSize: 12),
              // ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> powerAndToughness() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          widget.cardInfo.loyalty != null
              ? Stack(alignment: AlignmentDirectional.center, children: [
                  SvgPicture.asset(
                    'assets/images/Loyalty.svg',
                    width: 16,
                    height: 16,
                  ),
                  Text(
                    widget.cardInfo.loyalty ?? '0',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ])
              : (widget.cardInfo.power == null &&
                      widget.cardInfo.toughness == null)
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ...cardNameAndManaSymbol(),
          const Divider(
            thickness: 0.5,
            color: Colors.black,
          ),
          // ...cardTypeLine(),
          // const Divider(
          //   thickness: 1,
          //   color: Colors.black,
          // ),
          // const SizedBox(
          //   height: 4,
          // ),
          ...oracleText(),
          // ...flavorText(),
          // ...setNameAndPowerAndToughness(),
          // ...cardNameAndManaSymbol(),
          // //...cardTypeLine(),
          // ...oracleText(),
          ...powerAndToughness(),
          ...setName(),
        ],
      ),
    );
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
          // alignment: AlignmentDirectional.centerEnd,
          children: [
            (snapshot.connectionState == ConnectionState.done ||
                    !settings.useImagesFromNet)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (_hasInternetConnection && settings.useImagesFromNet)
                        ? _networkImageStream
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
                  ),
            if (widget.cardInfo.hasTwoSides &&
                (widget.cardInfo.imageUris?.normal == null) &&
                settings.useImagesFromNet)
              Positioned(
                left: (widget.mediaQuery.size.width -
                            widget.mediaQuery.padding.horizontal) /
                        2 /
                        2 -
                    50,
                top: (widget.mediaQuery.size.height / 3) - 50 - 10 - 15,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      CardImageDisplay.pictureLoaded = false;
                      getLocalImage(settings);
                      _side == 0 ? _side = 1 : _side = 0;
                    });
                  },
                  height: 45,
                  shape: const CircleBorder(),
                  color: const Color.fromRGBO(128, 128, 128, 0.5),
                  child: const Icon(
                    Icons.compare_arrows,
                    size: 30,
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

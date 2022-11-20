import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        10 -
        20;
  }

  List<Widget> cardNameAndManaSymbol() {
    return [
      Center(
        child: Text(
          widget.cardInfo.name ?? 'No name found for this card.',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      Text(
        widget.cardInfo.manaCost ?? '',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(
        height: 8,
      ),
    ];
  }

  List<Widget> cardTypeLine() {
    return [
      Text(widget.cardInfo.typeLine ?? '',
          style: const TextStyle(fontSize: 12)),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  List<Widget> oracleText() {
    return [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...cardTypeLine(),
              Text(
                widget.cardInfo.oracleText ?? 'No Oracle text found',
                style: const TextStyle(fontSize: 12),
              ),
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
          Text(
            '${widget.cardInfo.power ?? "-"}/${widget.cardInfo.toughness ?? "-"}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      const SizedBox(
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
          //...cardTypeLine(),
          ...oracleText(),
          ...powerAndToughness(),
          ...setName(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: true);
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
                  child: const Icon(
                    Icons.compare_arrows,
                    size: 30,
                    color: Colors.black87,
                  ),
                  height: 45,
                  shape: const CircleBorder(),
                  color: const Color.fromRGBO(128, 128, 128, 0.5),
                ),
              ),
          ],
        );
      },
    );
  }
}

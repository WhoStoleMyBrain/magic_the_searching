import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../scryfall_api_json_serialization/card_info.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/settings.dart';
import '../scryfall_api_json_serialization/image_uris.dart';

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

  Widget cardText() {
    return Card(
        child: Container(
      height:
          (widget.mediaQuery.size.height - widget.mediaQuery.padding.top - 30) -
              100 -
              32 -
              16 -
              32,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.cardInfo.name ?? 'No name found for this card.',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              Text(
                widget.cardInfo.manaCost ?? '',
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Text(widget.cardInfo.typeLine ?? '',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Text(
              widget.cardInfo.oracleText ?? 'No Oracle text found',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${widget.cardInfo.power ?? "-"}/${widget.cardInfo.toughness ?? "-"}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Set: ${widget.cardInfo.setName ?? 'Unknown Set'}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<Settings>(context, listen: true);
    // print(widget.cardInfo.purchaseUris?.toJson());
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
        child: const Icon(
          Icons.compare_arrows,
          size: 50,
          color: Colors.black87,
        ),
        height: 70,
        shape: const CircleBorder(),
        color: const Color.fromRGBO(128, 128, 128, 0.5),
      ),
    );
  }
}

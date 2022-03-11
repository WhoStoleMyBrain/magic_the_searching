import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as sys_paths;

import 'package:provider/provider.dart';

import '../providers/handedness.dart';
import '../providers/card_data_provider.dart';
import '../screens/card_detail_screen.dart';
import '../screens/history_screen.dart';
import '../widgets/card_display.dart' as card_display;
import '../widgets/enter_search_term.dart';

enum HandedMode {
  left,
  right,
}

class CardSearchScreen extends StatefulWidget {
  const CardSearchScreen({Key? key}) : super(key: key);

  @override
  State<CardSearchScreen> createState() => _CardSearchScreenState();
}

class _CardSearchScreenState extends State<CardSearchScreen> {
  void cardTapped(BuildContext ctx, String id) {
    Navigator.of(ctx).pushNamed(CardDetailScreen.routeName, arguments: id);
  }

  void _startEnterSearchTerm(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: EnterSearchTerm(
            startSearchForCard: (text) {
              return _startSearchForCard(ctx, text);
            },
          ),
          // behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  Future<void> _showFailedQuery(BuildContext ctx, String query) async {
    return showDialog<void>(
      context: ctx,
      builder: (bCtx) {
        return AlertDialog(
          title: const Text('No results found'),
          content: SingleChildScrollView(
              child: Text('No results matching \'$query\' found.')),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(bCtx).pop();
                },
                child: const Text('Okay'))
          ],
        );
      },
    );
  }

  Future<void> _startSearchForCard(BuildContext ctx, String text) async {
    final cardDataProvider = Provider.of<CardDataProvider>(ctx, listen: false);
    card_display.CardImageDisplay.pictureLoaded = false;
    cardDataProvider.query = text;
    bool requestSuccessful = await cardDataProvider.processSearchQuery();
    if (!requestSuccessful) {
      _showFailedQuery(ctx, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardDataProvider = Provider.of<CardDataProvider>(context);
    return Scaffold(
      appBar: MyAppBar(),
      body: cardDataProvider.cards.isEmpty
          ? const Center(child: Text('No cards found. Try searching for some!'))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2 / 4,
                // mainAxisExtent: 1,
              ),
              itemCount: cardDataProvider.cards.length,
              itemBuilder: (ctx, index) {
                return card_display.CardDisplay(
                  cardData: cardDataProvider.cards[index],
                  cardTapped: cardTapped,
                );
              },
            ),
      floatingActionButton: MyFloatingActionButtons(
        startEnterSearchTerm: _startEnterSearchTerm,
        startSearchForCard: _startSearchForCard,
      ),
    );
  }
}

class MyAppBar extends StatefulWidget with PreferredSizeWidget {
  MyAppBar({Key? key}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  bool handedMode = false;
  String title = '';

  void setTitle() {
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: true);
    setState(() {
      title = cardDataProvider.query.isNotEmpty
          ? (cardDataProvider.query[0] == '!'
              ? cardDataProvider.query.substring(1)
              : cardDataProvider.query)
          : '';
    });
    // print('title set to $title');
  }

  @override
  Widget build(BuildContext context) {
    final handednessProvider = Provider.of<Handedness>(context, listen: false);
    final cardDataProvider =
        Provider.of<CardDataProvider>(context, listen: false);
    setTitle();
    return AppBar(
      leadingWidth: 48.0,
      // leading: handedMode
      //     ? const Padding(
      //         padding: EdgeInsets.all(4.0),
      //         child: CircleAvatar(
      //           child: Text('R'),
      //           radius: 5.0,
      //         ),
      //       )
      //     : const Padding(
      //         padding: EdgeInsets.all(4.0),
      //         child: CircleAvatar(child: Text('L')),
      //       ),
      title: (cardDataProvider.cards.isNotEmpty && title != '')
          ? Text(
                  'Searched for: $title',
                  style: const TextStyle(fontSize: 18),
                  maxLines: 2,
                )
          : const Text(
              'No search performed yet',
              style: TextStyle(fontSize: 18),
            ),
      actions: [
        Switch(
          value: handedMode,
          onChanged: (value) {
            setState(
              () {
                handedMode = value;
                handednessProvider.handedness = value;
              },
            );
          },
        ),
        IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(HistoryScreen.routeName);
            },
            icon: const Icon(Icons.history)),
      ],
    );
  }
}

class MyFloatingActionButtons extends StatefulWidget {
  const MyFloatingActionButtons(
      {Key? key,
      required this.startEnterSearchTerm,
      required this.startSearchForCard})
      : super(key: key);
  final Function startEnterSearchTerm;
  final Function startSearchForCard;

  @override
  State<MyFloatingActionButtons> createState() =>
      _MyFloatingActionButtonsState();
}

class _MyFloatingActionButtonsState extends State<MyFloatingActionButtons> {
  // late File _storedImage;

  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;

  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  Future<void> _takePictureAndFireQuery(BuildContext ctx) async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (imageFile == null) {
      return;
    }
    // setState(() {
    //   _storedImage = File(imageFile.path);
    // });

    final appDir = await sys_paths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage =
        await File(imageFile.path).copy('${appDir.path}/$fileName');
    final recognisedText = await getCardNameFromImage(savedImage);
    // widget.startEnterSearchTerm(recognisedText);
    widget.startSearchForCard(ctx, recognisedText);

    // print(recognisedText.toString());
    // print('appDir:$appDir');
    // print('fileName:$fileName');
    // print('savedImage:${savedImage.toString()}');
    // widget.onSelectImage(savedImage);
  }

  Future<String> getCardNameFromImage(File image) async {
    isBusy = true;
    final inputImage = InputImage.fromFile(image);
    // final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText recognisedText =
        await textDetector.processImage(inputImage);
    for (TextBlock block in recognisedText.blocks) {
      // final Rect rect = block.rect;
      // final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      // final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        print(line.text);
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
    return recognisedText.blocks[0].lines[0].text;
    // print(recognisedText.text);
  }

  @override
  Widget build(BuildContext context) {
    final handednessProvider = Provider.of<Handedness>(context);
    return Container(
      padding: handednessProvider.handedness
          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Row(
        mainAxisAlignment: handednessProvider.handedness
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'search',
              onPressed: () => widget.startEnterSearchTerm(context),
              child: const Icon(Icons.search),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'camera',
              onPressed: () {
                _takePictureAndFireQuery(context);
              },
              child: const Icon(Icons.camera_enhance),
            ),
          ),
        ],
      ),
    );
  }
}

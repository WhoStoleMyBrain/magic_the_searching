import 'package:flutter/material.dart';
import 'package:magic_the_searching/providers/scryfall_provider.dart';
import 'package:magic_the_searching/screens/camera_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/constants.dart';
import '../helpers/search_start_helper.dart';
import '../screens/search_page.dart';

class MyMainFloatingActionButtons extends StatefulWidget {
  const MyMainFloatingActionButtons({super.key});
  @override
  State<MyMainFloatingActionButtons> createState() =>
      _MyMainFloatingActionButtonsState();
}

class _MyMainFloatingActionButtonsState
    extends State<MyMainFloatingActionButtons> {
  late ScryfallProvider scryfallProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scryfallProvider = Provider.of<ScryfallProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'search',
              onPressed: () async {
                await Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                )
                    .then((value) {
                  if (value != null) {
                    SearchStartHelper.startSearchForCard(
                      context,
                      value[Constants.contextSearchTerm],
                      value[Constants.contextLanguages],
                      value[Constants.contextCreatureTypes],
                      value[Constants.contextKeywords],
                      value[Constants.contextCardTypes],
                      value[Constants.contextSet],
                      value[Constants.contextCmcValue],
                      value[Constants.contextCmcCondition],
                      value[Constants.contextColors],
                    );
                  }
                });
              },
              child: const Icon(Icons.search),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CameraScreen.routeName);
              },
              child: const Icon(Icons.camera),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../helpers/process_image_taking.dart';
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
                      value['searchTerm'],
                      value['languages'],
                      value['creatureType'],
                      value['keywordAbility'],
                      value['cardType'],
                      value['set'],
                      value['cmcValue'],
                      value['cmcCondition'],
                      value['colors'],
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
              heroTag: 'camera',
              onPressed: () {
                ProcessImageTaking.takePictureAndFireQuery(context);
              },
              child: const Icon(Icons.camera_enhance),
            ),
          ),
        ],
      ),
    );
  }
}

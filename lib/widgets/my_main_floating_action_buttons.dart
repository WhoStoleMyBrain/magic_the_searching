import 'package:flutter/material.dart';

import '../helpers/process_image_taking.dart';
import '../helpers/search_start_helper.dart';

class MyMainFloatingActionButtons extends StatefulWidget {
  const MyMainFloatingActionButtons({Key? key}) : super(key: key);
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
              onPressed: () => SearchStartHelper.startEnterSearchTerm(context),
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

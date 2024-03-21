import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ColorPickerPage extends StatefulWidget {
  ColorPickerPage(
      {super.key,
      required this.startColor,
      required this.setNewColor,
      required this.colorName});

  Color startColor;
  final Function(Color newColor) setNewColor;
  final String colorName;

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Select ${widget.colorName} Color'),
      subtitle: Text(
        '${ColorTools.materialNameAndCode(widget.startColor, colorSwatchNameMap: colorsNameMap)} '
        'aka ${ColorTools.nameThatColor(widget.startColor)}',
      ),
      trailing: ColorIndicator(
          width: 40,
          height: 40,
          borderRadius: 0,
          color: widget.startColor,
          elevation: 1,
          onSelectFocus: false,
          onSelect: () async {
            // Wait for the dialog to return color selection result.
            final Color newColor = await showColorPickerDialog(
              // The dialog needs a context, we pass it in.
              context,
              widget.startColor,
              title: Text('ColorPicker',
                  style: Theme.of(context).textTheme.titleLarge),
              width: 40,
              height: 40,
              spacing: 0,
              runSpacing: 0,
              borderRadius: 0,
              wheelDiameter: 165,
              enableOpacity: true,
              showColorCode: true,
              colorCodeHasColor: true,
              pickersEnabled: <ColorPickerType, bool>{
                ColorPickerType.wheel: true,
              },
              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                copyButton: true,
                pasteButton: true,
                longPressMenu: true,
              ),
              actionButtons: const ColorPickerActionButtons(
                okButton: true,
                closeButton: true,
                dialogActionButtons: false,
              ),
              transitionBuilder: (BuildContext context, Animation<double> a1,
                  Animation<double> a2, Widget widget) {
                final double curvedValue =
                    Curves.easeInOutBack.transform(a1.value) - 1.0;
                return Transform(
                  transform:
                      Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                  child: Opacity(
                    opacity: a1.value,
                    child: widget,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
              constraints: const BoxConstraints(
                  minHeight: 480, minWidth: 320, maxWidth: 320),
            );
            widget.setNewColor(newColor);
            setState(() {
              widget.startColor = newColor;
            });
          }),
    );
  }
}

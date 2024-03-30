import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../helpers/navigation_helper.dart';
import '../providers/color_provider.dart';
import '../widgets/app_drawer.dart';
import '../helpers/constants.dart';

class AboutScreen extends StatefulWidget {
  static const routeName = '/about';
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  TextStyle style = const TextStyle(fontSize: 18, color: Colors.black);

  final mailtoLink = Mailto(
      to: [
        'magicthesearching@gmail.com',
      ],
      subject: 'Feedback to or Problems with Magic the Searching',
      body:
          'Enter your suggestions or a description of your errors below. Please try to be as precise as possible and feel free to append screenshots, images or links to further clarify your request! Thank you!');
  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<ColorProvider>(context);
    return PopScope(
        canPop: Navigator.canPop(context),
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (!Navigator.canPop(context)) {
            NavigationHelper.showExitAppDialog(context);
          }
        },
        child: Container(
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 0.9],
              colors: [
                colorProvider.backgroundColor1,
                colorProvider.backgroundColor2,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('About'),
            ),
            drawer: const AppDrawer(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(text: Constants.aboutPage1, style: style),
                        TextSpan(
                            text: "magicthesearching@gmail.com",
                            style: TextStyle(
                                fontSize: style.fontSize,
                                color: Colors.deepPurple.shade600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                _launchURL(mailtoLink.toString());
                              }),
                        TextSpan(text: Constants.aboutPage2, style: style),
                        TextSpan(
                            text: Constants.buyMeACoffee,
                            style: TextStyle(
                                fontSize: style.fontSize,
                                color: Colors.deepPurple.shade600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                _launchURL(Constants.buyMeACoffee);
                              }),
                      ])),
                    ]),
              ),
            ),
          ),
        ));
  }

  Future<void> _launchURL(String webpage) async {
    if (!await launchUrlString(webpage)) {
    //if (!await launchUrl(Uri.parse(webpage))) {
      throw 'Could not launch $webpage';
    }
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:provider/provider.dart';

import '../helpers/navigation_helper.dart';
import '../providers/color_provider.dart';
import '../widgets/app_drawer.dart';
import '../helpers/constants.dart';

class PrivacyPolicyPage extends StatefulWidget {
  static const routeName = '/privacy-policy';
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  TextStyle style = const TextStyle(fontSize: 18, color: Colors.black);

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
              title: const Text('Privacy Policy'),
            ),
            drawer: const AppDrawer(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Text(Constants.privacyInformation1, style: style),
                    Text(Constants.privacyInformation2, style: style),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(Constants.privacyInformation3, style: style),
                    const SizedBox(
                      height: 12,
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: Constants.privacyInformation41, style: style),
                      TextSpan(
                          text: Constants.privacyInformation42,
                          style: TextStyle(
                              fontSize: style.fontSize,
                              color: Colors.deepPurple.shade600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              _launchURL("https://www.scryfall.com");
                            }),
                      TextSpan(
                          text: Constants.privacyInformation43, style: style)
                    ])),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(Constants.privacyInformation5, style: style),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(Constants.privacyInformation6, style: style),
                    const SizedBox(
                      height: 12,
                    ),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          style: TextStyle(
                              fontSize: style.fontSize,
                              color: Colors.deepPurple.shade600),
                          text: "Privacy Policy",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              _launchURL(Constants.privacyInformation7);
                            }),
                    ]))
                  ]),
                ),
              ),
            ),
          )),
    );
  }

  Future<void> _launchURL(String webpage) async {
    if (!await url.launchUrl(Uri.parse(webpage))) {
      throw 'Could not launch $webpage';
    }
  }
}

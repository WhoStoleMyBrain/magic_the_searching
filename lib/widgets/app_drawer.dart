import 'package:flutter/material.dart';
import 'package:magic_the_searching/screens/about_screen.dart';
import 'package:magic_the_searching/screens/card_search_screen.dart';
import 'package:magic_the_searching/screens/help_screen.dart';
import 'package:magic_the_searching/screens/history_screen.dart';
import 'package:magic_the_searching/screens/privacy_policy_page.dart';
import 'package:provider/provider.dart';

import '../providers/color_provider.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);
    return Drawer(
      child: Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.9],
            colors: [
              colorProvider.appDrawerColor1,
              colorProvider.appDrawerColor2,
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Navigation'),
              automaticallyImplyLeading: false,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(CardSearchScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(HistoryScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(SettingsScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(HelpScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text("Privacy Policy"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(PrivacyPolicyPage.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AboutScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

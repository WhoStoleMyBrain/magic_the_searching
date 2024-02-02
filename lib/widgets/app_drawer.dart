import 'package:flutter/material.dart';
import 'package:magic_the_searching/screens/card_search_screen.dart';
import 'package:magic_the_searching/screens/help_screen.dart';
import 'package:magic_the_searching/screens/history_screen.dart';

import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Navigation'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () {
              Navigator.of(context).pushNamed(CardSearchScreen.routeName);
              // Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.of(context).pushNamed(HistoryScreen.routeName);
              // .pushReplacementNamed(HistoryScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
              // .pushReplacementNamed(SettingsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help'),
            onTap: () {
              Navigator.of(context).pushNamed(HelpScreen.routeName);
              // Navigator.of(context).pushReplacementNamed(HelpScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}

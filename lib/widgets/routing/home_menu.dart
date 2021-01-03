import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover
                ),
              ),
              // child: Text("Puk"), // TODO: Add user icon if auth
              alignment: Alignment.bottomLeft,
            ),
          ),
          ListTile(
            trailing: const Icon(Icons.settings),
            title: Text(localization.settings),
            onTap: () => Navigator.popAndPushNamed(context, "settings"),
          ),
          ListTile(
            trailing: const Icon(Icons.archive),
            title: Text(localization.cachedArticles),
            onTap: () => Navigator.popAndPushNamed(context, 'articles/cached'),
          ),
          ListTile(
            trailing: const Icon(Icons.filter_alt),
            title: Text(localization.filters),
            onTap: () => Navigator.popAndPushNamed(context, 'filters'),
          ),
        ],
      ),
    );
  }
}
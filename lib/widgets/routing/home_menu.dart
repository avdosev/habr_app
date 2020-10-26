import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            title: Text('Settings'),
            onTap: () {
              // Open setting page
              Navigator.pop(context);
              Navigator.pushNamed(context, "settings");
            },
          ),
          ListTile(
            trailing: const Icon(Icons.archive),
            title: Text("Cached articles"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'articles/cached');
            },
          )
        ],
      ),
    );
  }
}
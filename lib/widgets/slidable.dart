import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableArchive extends StatelessWidget {
  final Widget child;
  final VoidCallback onArchive;
  SlidableArchive({this.child, this.onArchive});

  @override
  Widget build(BuildContext context) {
    return Slidable(
        child: child,
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        secondaryActions: <Widget>[
          IconSlideAction(
              caption: 'Archive',
              color: Theme.of(context).scaffoldBackgroundColor,
              icon: Icons.archive,
              onTap: onArchive
          ),
        ]
    );
  }
}
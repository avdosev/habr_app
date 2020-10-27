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

class SlidableDelete extends StatelessWidget {
  final Key key;
  final Widget child;
  final VoidCallback onDelete;
  SlidableDelete({this.child, this.onDelete, @required this.key});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onDismissed: (actionType) {
          onDelete();
        },
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.secondary: 0.3
        },
      ),
      child: child,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0,
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Theme.of(context).scaffoldBackgroundColor,
            icon: Icons.delete,
        ),
      ]

    );
  }
}
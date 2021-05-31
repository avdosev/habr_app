import 'package:flutter/material.dart';

void notifySnackbarText(BuildContext context, Object message) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message.toString())));
}

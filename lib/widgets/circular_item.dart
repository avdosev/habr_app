import 'package:flutter/material.dart';

class CircularItem extends StatelessWidget {
  const CircularItem();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: const CircularProgressIndicator()
    );
  }
}
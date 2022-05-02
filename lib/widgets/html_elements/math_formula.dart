import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathFormula extends StatelessWidget {
  final String formula;

  const MathFormula(this.formula, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      formula,
      mathStyle: MathStyle.text,
      textStyle: Theme.of(context).textTheme.bodyText2,
    );
  }
}

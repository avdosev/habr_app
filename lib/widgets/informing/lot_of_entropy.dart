import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LotOfEntropy extends StatelessWidget {
  const LotOfEntropy();

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/lot_of_entropy.webp", height: 300, width: 300,),
          SizedBox(height: 30,),
          Text(AppLocalizations.of(context).appError),
        ]
    );
  }
}
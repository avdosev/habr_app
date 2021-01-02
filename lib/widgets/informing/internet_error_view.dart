import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LossInternetConnection extends StatelessWidget {
  final VoidCallback onPressReload;


  const LossInternetConnection({
    @required
    this.onPressReload
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/ufo.png"),
          SizedBox(height: 30,),
          Text(localization.lossInternet),
          SizedBox(height: 10),
          FlatButton(
            onPressed: onPressReload,
            child: Text(localization.reload),
          )
        ]
    );
  }
}
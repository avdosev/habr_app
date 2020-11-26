import 'package:flutter/material.dart';

class LossInternetConnection extends StatelessWidget {
  final VoidCallback onPressReload;


  const LossInternetConnection({
    @required
    this.onPressReload
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/ufo.png"),
          SizedBox(height: 30,),
          Text("НЛО прилетело и потеряло соединение"),
          SizedBox(height: 10),
          FlatButton(
            onPressed: onPressReload,
            child: Text("reload"),
          )
        ]
    );
  }
}
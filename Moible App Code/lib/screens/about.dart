import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gas Monitoring System', style: TextStyle(color: Colors.blue,fontSize: 20, fontWeight: FontWeight.bold),),
      content: Container(
        child: Text("The aim of this system is to provide a safety design by detecting the leakage of LPG used in our residential premises. The leakage of gas is sensed by the gas sensor and notified to the user through the android app, the combination of the gas sensor and the android app make the system an advanced one. The system would determine the weight of the gas cylinder and alerts the user when the level of the gas falls below average. Also, the system alerts the user when there is a fire outbreak through the android app."),
      ),
      actions: <Widget>[
        RaisedButton(onPressed: ()=>Navigator.pop(context),child: Text('Ok'),)
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mqtt/screens/login_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white70
        ),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
           Padding(
             padding: EdgeInsets.all(25.0),
             child: CircleAvatar(
               radius: 100,
               child:  Icon(Icons.local_gas_station,color: Colors.green,size: 150.0,),
             ),
           ),
            Padding(
              padding:EdgeInsets.all(15.0),
              child:  Text("Gas Monitoring System",
                style: TextStyle(
                    fontSize: 30.0, fontWeight:FontWeight.bold, color: Colors.blue
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
               "This system measures the weight of your gas and also detect fire outbreak and gas leakages.",
                style: TextStyle(
                    fontSize: 21.0, fontWeight: FontWeight.bold, color: Colors.green
                ),
              ),
            ),
           Padding(
             padding:EdgeInsets.all(15.0),
             child:  SizedBox(
               height: 50.0,
               width: double.infinity,
               child: RaisedButton(
                 onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginPage()));},
                 color: Colors.blue,
                 child: Text('Get Started', style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
               ),
             ),
           ),
          ],
        ),
      ),
    );
  }
}

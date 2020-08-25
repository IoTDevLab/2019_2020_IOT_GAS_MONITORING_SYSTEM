import 'package:flutter/material.dart';
import 'package:mqtt/mqtt/mqtt.dart';
import 'package:mqtt/screens/home_screen.dart';
import 'package:mqtt/widgets/drawer.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool _isLoading = false;
  double _temp = 0.0;
  double _hum = 0.0;
  String _fire = "No Fire Detected";
  String _smoke = "No Leakage Detected";
  double _weight = 0.0;

  @override
  void initState() {
    super.initState();
    Mqttwrapper().mqttController.stream.listen(listenToClient); //construct to listen to stream control
  }

//  @override
//  void dispose() {
//
//  }
//function to grab data from stream control
  void listenToClient(Map data) {
    if (this.mounted) {
      setState(() {
        print("I am coming from the iot device $data");
        double t = double.parse(data["temperature"].toString());
        double h = double.parse(data["humidity"].toString());
        double w = double.parse(data["weight"].toString());

        double f = double.parse(data["fire"]);
        double s = double.parse(data["smoke"]);


        _isLoading = true;
        _temp = t;
        _hum = h;
        if (f==1){
          _fire ="Fire Detected";
        }
        else{
          _fire ="No Fire Detected";
        }
        if (s>400){
          _smoke ="Gas Leakage detected";
        }
        else {
          _smoke="No Leakage Detected";
        }
        _weight = w;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child:  MQTTDrawer(),
      ),
      appBar: AppBar(
        title: Text('DashBoard'),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
        children: <Widget>[
          SizedBox(height: 20.0,),
          Card(
            child: ListTile(
              leading: Icon(Icons.wb_sunny,color: Colors.blueAccent,size: 25,),
              title: Text('Temperature'),
              subtitle: Text(
                _temp.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              trailing: Text('c'),
              onTap: (){},
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            child: ListTile(
              leading: Icon(Icons.bug_report,color: Colors.blueAccent,size: 25,),
              title: Text('Humidity'),
              subtitle: Text(
                _hum.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              trailing: Text('%'),
              onTap: (){},
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            child: ListTile(
              leading: Icon(Icons.line_weight,color: Colors.blueAccent,size: 25,),
              title: Text('Weight'),
              subtitle: Text(
                _weight.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              trailing: Text('%'),
              onTap: (){},
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            child: ListTile(
              leading: Icon(Icons.warning,color: Colors.blueAccent,size: 25,),
              title: Text('Fire Detected'),
              subtitle: Text(
                _fire,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              trailing: Text('*'),
              onTap: (){},
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_gas_station,color: Colors.blueAccent,size: 25,),
              title: Text('Gas Leaking'),
              subtitle: Text(
                _smoke.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              trailing: Text('~'),
              onTap: (){},
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            child: ListTile(
              leading: Icon(Icons.graphic_eq,color: Colors.blueAccent,size: 25,),
              title: Text('Weight Chart'),
              subtitle: Text('Graph of Weight'),
              trailing: Icon(Icons.arrow_forward_ios,size: 50.0,),
              onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WeightGraph()));},
            ),
          )
        ],
      ),
    );
  }
}

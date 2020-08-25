import 'package:flutter/material.dart';
import 'package:mqtt/mqtt/mqtt.dart';
import 'package:mqtt/utils/databasehelper.dart';
import 'package:mqtt/widgets/drawer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class  WeightGraph extends StatefulWidget {
  WeightGraph({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyTempGraphPageState createState() => _MyTempGraphPageState();
}
class SubscriberSeries {
  final String time;
  final double weight;

  SubscriberSeries(
      {@required this.time,
        @required this.weight,});
}

class SubscriberChart extends StatelessWidget {
  final List<SubscriberSeries> data;
  SubscriberChart({@required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 400,
        padding: EdgeInsets.all(10),
        child:
        Card(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:Column(
                    children: <Widget>[
                      Text(
                        " Weight",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      Expanded(
                          child:
                          SfCartesianChart(
                              primaryXAxis: CategoryAxis(
//                                  maximumLabels: 5,
                                  labelPlacement: LabelPlacement.onTicks,
                                  labelRotation: 90,
                                  title: AxisTitle(
                                      text: 'TIME',
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Roboto',
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w300,
                                      )
                                  )
                              ),

                              series: <ChartSeries>[
                                // Renders line chart
                                AreaSeries<SubscriberSeries, String>(
                                    dataSource: data,
                                    color: Colors.lightBlue,
                                    borderColor: Colors.lightBlueAccent,
                                    borderWidth: 5,
                                    xValueMapper: (SubscriberSeries sales, _) => sales.time,
                                    yValueMapper: (SubscriberSeries sales, _) => sales.weight

                                )
                              ]
                          )
                      )
                    ]
                )
            )
        )
    );
  }
}

class _MyTempGraphPageState extends State< WeightGraph> {
  bool _isLoading = false;
  double _weight = 0.0;
  final List<SubscriberSeries> weightpoints= [];

  @override
  void initState(){
    super.initState();
    Mqttwrapper().mqttController.stream.listen(listenToClient);
    fetchValues();
  }

  fetchValues() {
    DatabaseHelper().getReadingWeightList().then((data) {
      for (Map map in data) {
        weightpoints.add(SubscriberSeries(
          time: map['time'],
          weight: double.tryParse('${map['weight']}'),
        ));
        print('time: ${map['time']}\tweight: ${double.tryParse('${map['weight']}')}');
      }
      setState((){});
    });
  }


  Future myTypedFuture() async {
    await Future.delayed(Duration(seconds: 4));
    fetchValues();
  }

  void listenToClient(final data) {
    if (this.mounted) {
      setState(() {
        print("I am coming from the iot device $data");
        double w = double.parse(data["weight"].toString());

        _isLoading = true;
        _weight = w;
        weightpoints.clear();
        print('List removed');
        myTypedFuture();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weight Graph', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
//        elevation: 0.5,
      ),
      body:ListView(children: <Widget>[
        SizedBox(height: 4.0,),
        _createListTile("Weight",  _weight.toString(), "%",),
        SizedBox(height: 5.0,),
        SubscriberChart(
          data: weightpoints,
        )]),
      drawer: Drawer(child: MQTTDrawer()),
    );
  }


  _createListTile(String title, String value, String initials) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 5.0, right: 5.0),
      child: Card(
        elevation: 0.5,
        child: Container(
          height: 130.0,
          child: ListTile(
            trailing: Container(
              alignment: Alignment.center,
              height: 50.0,
              width: 30.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(initials, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold ),),
            ),

            title:  Text(title, style: TextStyle(
                color: Colors.black87,
                fontSize: 30.0,
                fontWeight: FontWeight.bold
            ),) ,
            subtitle: !_isLoading ? Text(value, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40.0,),) : Center(child:CircularProgressIndicator(strokeWidth: 1.0,)),
          ),
        ),
      ),
    );
  }
  @override
  void dispose(){
    super.dispose();
  }
}

class Datareading {
  int id;
  DateTime time;
  double temperature;
  double humidity;
  double fire;
  double smoke;
  double weight;
  Datareading({this.id, this.time, this.temperature,  this.humidity, this.fire, this.smoke, this.weight}); // creating database constructors

  //mapping data
  Datareading.fromJson(Map<String, dynamic> map) :
        temperature = double.tryParse("${map['temperature']}"),
        humidity =double.tryParse("${map['humidity']}"),
        fire =double.tryParse("${map['fire']}"),
        smoke =double.tryParse("${map['smoke']}"),
        weight =double.tryParse("${map['weight']}");

  Map<String, dynamic> toJson()=> {
    'temperature':temperature,
    'humidity':humidity,
    'fire':fire,
    'smoke':smoke,
    'weight':weight,
  };
}
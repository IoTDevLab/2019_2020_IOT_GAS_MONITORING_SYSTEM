import 'package:mqtt/models/dataread.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
//database helper class
class DatabaseHelper{

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String readingstable = 'SensorRecords';
  String colId= 'id';
  String coltime = 'time';
  String coltemperature = 'temperature';
  String colhumidity = 'humidity';
  String colfire = 'fire';
  String colsmoke = 'smoke';
  String colweight = 'weight';

  DatabaseHelper._createInstance();

  factory DatabaseHelper(){
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if (_database == null){
      _database = await initializedatabase();
    }
    return _database;
  }
//function to initialize database
  Future<Database> initializedatabase() async {
    Directory directory= await getApplicationDocumentsDirectory();
    String path = directory.path + 'iotgasmonitor.db';
    var sensordata= await openDatabase(path,version: 1,onCreate: _createDb );
    return sensordata;
  }
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $readingstable($colId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            '$coltime TIMESdTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,'
            '$coltemperature REAL,'
            '$colhumidity REAL,'
            '$colfire REAL,'
            '$colsmoke REAL,'
            '$colweight REAL)');
  }
//function to select weight and time from sqllite for temperature chart
  Future<dynamic> getReadingWeightList() async {
    Database db = await this.database;
    List<Map<dynamic, dynamic>> weightgraph = await db.rawQuery('select $coltime, $colweight FROM $readingstable ORDER BY $colId DESC limit 5');
    return weightgraph;
  }
//function to insert database
  InsertDatareading(Datareading datareading) async{
    Database db = await this.database;
    var dataread = await db.insert(readingstable, datareading.toJson());
    print('Data inserted');
    return dataread;
  }
  //function to delete database
  deleteAll() async {
    Database db = await this.database;
    db.delete(readingstable).then((i)=>print('Database deleted'));
  }

}
/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:io';
import 'package:mqtt/models/dataread.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';
import 'package:mqtt/utils/databasehelper.dart';


//creating mqtt class
class Mqttwrapper {
  StreamController<Map<String, dynamic>> mqttController =
  StreamController.broadcast();
  static final Mqttwrapper instance = Mqttwrapper._internal();

  factory Mqttwrapper() => instance;

  String email;
  String password;

  Mqttwrapper._internal();

  var value = 'Hello MQTT';

  DatabaseHelper databaseHelper = DatabaseHelper();

  /// An annotated simple subscribe/publish usage example for mqtt_client. Please read in with reference
  /// to the MQTT specification. The example is runnable, also refer to test/mqtt_client_broker_test...dart
  /// files for separate subscribe/publish tests.
  MqttClient client;
  String clientIdentifier = 'android';
//function to connect MQTT
  Future<MqttClient> initializemqtt({String email, String password}) async {
    this.email = email;
    this.password = password;

    final MqttClient client = MqttClient("mqtt.dioty.co", "");
    client.port = 1883;
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.onConnected = _onConnect;
    client.onDisconnected = _onDisconnect;
    client.onSubscribed = onSubscribed;
    final MqttConnectMessage connMess = new MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .keepAliveFor(60);
    print("EXAMPLE::MQTT client connecting....");
    client.connectionMessage = connMess;
    try {
      await client.connect(email, password);
    } catch (e) {
      print("EXAMPLE::client exception - $e");
      client.disconnect();
      return client;
    }

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print("EXAMPLE::MQTT client connected");

      /// Ok, lets try a subscription
      final String topictwo =
          "/${this.email}/SensorData"; // Not a wildcard topic
      client.subscribe(topictwo, MqttQos.atMostOnce);

      /// The client has a change notifier object(see the Observable class) which we then listen to to get
      /// notifications of published updates to each subscribed topic.
      client.updates.listen((List<MqttReceivedMessage> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        print(
            "EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->");
        print("");
        final String topicSensor = "/${this.email}/SensorData";
        if (("${c[0].topic}") == (topicSensor)) {
          final datasensor = json.decode(pt);
          String temp=datasensor[0].toString();
          String hum=datasensor[1].toString();
          String fire=datasensor[2].toString();
          String smoke=datasensor[3].toString();
          String weight=datasensor[4].toString();
         String rawJson = '{"temperature":"$temp","humidity":"$hum","fire":"$fire","smoke":"$smoke","weight":"$weight"}';
         print(rawJson);
          final decodata = json.decode(rawJson);
          mqttController.add(decodata);
          databaseHelper.InsertDatareading(Datareading.fromJson(decodata));
        }
      });
    } else {
      print(
          "EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus.state}");
      client.disconnect();
      exit(-1);
    }
    this.client = client;
    return client;
  }

  Future<bool> _connectToClient() async {
    if (client != null &&
        client.connectionStatus.state == MqttConnectionState.connected) {
    } else {
      client = await initializemqtt(email: this.email, password: this.password);
      if (client == null) {
        return false;
      }
    }
    return true;
  }

/// The subscribed callback
void onSubscribed(String topic) {
  print("EXAMPLE::Subscription confirmed for topic $topic");
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print("EXAMPLE::OnDisconnected client callback - Client disconnection");
  exit(-1);
}
//connecting MQTT
_onConnect() {
  print("mqtt connected");
}
//disconnecting MQTT
_onDisconnect() {
  print("mqtt disconnected");
}

}
@override
void dispose() {
  Mqttwrapper().mqttController.close();
}
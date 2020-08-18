#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <dht.h>
#include <Q2HX711.h>
#include <SoftwareSerial.h>


SoftwareSerial mySerial(19,18);



dht DHT;

float analogSensor;
int fire;
float y1 = 150.0; // calibrated mass to be added
float avg_size = 10.0; // amount of averages for each mass measurement



//float empty = 2000;
//float full = 5000;

float empty = 200; //intial weight of the gas cylinder when empty in grams
float full = 500; // weight of the gas cylinder when full in grams

const byte hx711_data_pin = 3;
const byte hx711_clock_pin = 4;
//8442370
//8509406

long x0 = 8442370L;
long x1 = 8509406L;



Q2HX711 hx711(hx711_data_pin, hx711_clock_pin); // prep hx711
#define FLAME 12
#define dht_apin 9
#define smoke 8
#define buzzer 10
#define LED   5
long lastMsg = 0;
char msg[50];
LiquidCrystal_I2C lcd(0x3F, 16, 2);

void setup2() {
  pinMode(FLAME, INPUT); 
  pinMode(buzzer, OUTPUT);
  pinMode(smoke, INPUT);
  pinMode(LED, OUTPUT);


   mySerial.begin(9600);   // Setting the baud rate of GSM Module 
  Serial.begin(9600); 
  delay(100);

  //SendMessage("HELLO");
  lcd.init(); // initialize the lcd
 
  
  lcd.backlight();
  lcd.setCursor(0,0);
  lcd.println("Ready Test");
  delay(5000);
  lcd.clear();
}

String ftos(float num){
  char charVal[10];               //temporarily holds data from vals 
  String stringVal = "";     //data on buff is copied to this string
  dtostrf(num, 4, 4, charVal);  //4 is mininum width, 4 is precision; float value is copied onto buff
  //convert chararray to string
  for(int i=0;i<sizeof(charVal);i++)
  {
    stringVal+=charVal[i];
  }
}
void loop2() {
  float current = weight();
  float t = percentage(current, empty, full);

  lcd.setCursor(0,0);
  lcd.println("% of Gas Left  :");
  lcd.setCursor(0,1);
  lcd.println(t);
  lcd.print("%");
   delay(5000);
    
  lcd.clear();
 
  Serial.print("% of Gas Left  :");
  Serial.print(t);
  Serial.println("%");

  if(t < 50 and t>0){
    alarmsandlight();
    Serial.println("Your gas is below 50%");
    lcd.setCursor(0,0);
    lcd.println("Your gas is ");
    lcd.setCursor(0,1);
    lcd.println("below 50%");
    delay(5000);
   
    }
    if(t==0){
      alarmsandlight();
      Serial.println("Your gas cylinder is empty");
    lcd.setCursor(0,0);
    lcd.println("Your gas is ");
    lcd.setCursor(0,1);
    lcd.println("empty");
    delay(5000);
      
      }
  if (mySerial.available()>0)

   Serial.write(mySerial.read());

  flame();
  temphum();
  gasdetect();
  delay(5000);

  long time = millis();
  if (time - lastMsg > 30000) {
    lastMsg = time;

    // Convert the value to a char array
    char TempString[8];
    dtostrf(DHT.temperature, 1, 2, TempString);
    Serial.print("Temperature: ");
    Serial.println(TempString);

    // Convert the value to a char array
    char HumiString[8];
    dtostrf(DHT.humidity, 1, 2, HumiString);
    Serial.print("Humidity: ");
    Serial.println(HumiString);

    // Convert the value to a char array
    char LeakString[8];
    dtostrf(analogSensor, 1, 2, LeakString);
    Serial.print("Leakage: ");
    Serial.println(LeakString);

    // Convert the value to a char array
    char FireString[8];
    dtostrf(fire, 1, 2, FireString);
    Serial.print("Fire: ");
    Serial.println(FireString);

    // Convert the value to a char array
    char WeightString[8];
    dtostrf(t, 1, 2, WeightString);
    Serial.print("Weight: ");
    Serial.println(WeightString);

    char sensorReading[270];
//    String sensorValues = "{ \"temperature\": \"" + String(TempString) + "\", \"humidity\" : \"" + String(HumiString) + "\"\"fire\": \"" + String(FireString) + "\",\"leakage\": \"" + String(LeakString) + "\",\"weight\": \"" + String(WeightString) + "\"}";
    
    snprintf(sensorReading,268,"[%s,%s,%s,%s,%s]",String(TempString).c_str(),String(HumiString).c_str(),String(FireString).c_str(),String(LeakString).c_str(),String(WeightString).c_str());
    Serial.println(sensorReading);
    Serial.println("PUBLISH 1st");
    mqtt.publish(topicLed, sensorReading);

  }


  delay(1000);

}


//function to measure the weight of gas in grams
float weight() {
  // averaging reading
  long reading = 0;
  for (int jj=0;jj<int(avg_size);jj++){
    reading+=hx711.read();
  }
  reading/=long(avg_size);
  // calculating mass based on calibration and linear fit
  float ratio_1 = (float) (reading-x0);
  float ratio_2 = (float) (x1-x0);
  float ratio = ratio_1/ratio_2;
  float current = y1*ratio;
  Serial.println("Raw: ");
  Serial.print(reading);
  Serial.print(", ");
  Serial.print("Weight of Gas:     ");
  Serial.print(current);
  Serial.println("grams"); 
delay(5000);
return current;
}
// function to measure the percentage of the gas left
float percentage(float current, float empty, float full){
    return ( (current - empty) / (full - empty) )*100;
}
  
// function to detect temperature and humidity
void temphum(){
    
    DHT.read11(dht_apin);
    lcd.setCursor(0,0);
    lcd.print("Current humi = ");
    lcd.setCursor(0,1);
    lcd.print(DHT.humidity);
    Serial.print("Current Humidity: ");
    Serial.println(DHT.humidity);
    Serial.print("temperature = ");
    Serial.println(DHT.temperature);


    delay(5000);
    lcd.clear();
    //lcd.print("%  ");
    lcd.setCursor(0,0);
    lcd.print("temperature = ");
    lcd.setCursor(0,1);
    lcd.print(DHT.temperature); 
    lcd.println("C  ");
    delay(5000);
    lcd.clear();
  
  }

  //Function to detect gas leakage
void gasdetect(){
    analogSensor = analogRead(smoke);
   // float value = (analogSensor/1024)*5.0;
    int sensorThres = 400;
    //float sensorThres = 3.5;
    Serial.println("Pin A0: ");
    Serial.println(analogSensor);
   // Serial.println(value);

    // Checks if it has reached the threshold value
  if (analogSensor> sensorThres)
  {
     Serial.println("Gas Leakage Detected");
      lcd.setCursor(0,0);
    lcd.println("GAS Leakage");
    lcd.setCursor(0,1);
    lcd.println("detected");
    delay(5000);
    lcd.clear();
     alarmsandlight();
     
  }
  else
  {
     Serial.println(" No Gas Leakage Detected");
       lcd.setCursor(0,0);
    lcd.println("No GAS Leakage");
    lcd.setCursor(0,1);
    lcd.println("detected");
    delay(5000);
    lcd.clear();
   
  }
  delay(100);
    
    

  
}
// function to detect flame
void flame(){
  fire = digitalRead(FLAME);
  if (fire == 1)
  {
    Serial.println("Flame detected...! take action immediately.");
    //SendMessage("flame detected");
  lcd.setCursor(0,0);
  lcd.println("Flame detected");
    alarmsandlight();
     
    //digitalWrite(buzzer, HIGH);
    //digitalWrite(LED, HIGH);
    //delay(200);
   //// digitalWrite(LED, LOW);
    delay(200);
    lcd.clear();
  }
  else
  {
    Serial.println("No flame detected. stay cool");
    lcd.setCursor(0,0);
    lcd.println("No flame");
    lcd.setCursor(0,1);
    lcd.println("detected");
    delay(5000);
    lcd.clear();
   // digitalWrite(buzzer, LOW);
    //digitalWrite(LED, LOW);
  }
  delay(1000);
  
  
}


// function of the buzzer(to sound an alarm) and light
void alarmsandlight(){
  unsigned char i;


    for(i=0;i<10;i++){

      digitalWrite(buzzer,HIGH);
      digitalWrite(LED,HIGH);
      delay(100);
      digitalWrite(buzzer,LOW);
      digitalWrite(LED,LOW);

      delay(100);
      
      
      }
 

    }
  

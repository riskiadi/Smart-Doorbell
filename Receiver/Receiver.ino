#include <NTPClient.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h>
#include <FirebaseESP8266.h>
#include <FirebaseESP8266HTTPClient.h>
#include <FirebaseJson.h>
#include "Neotimer.h"
#include "PinDefine.h"

//Define
#define FIREBASE_HOST "manyaran-sistem.firebaseio.com"
#define FIREBASE_AUTH "vGw7kpq6yTrIjPLVVciDBpqMoZxAkmaERSVRqZWt"
#define WIFI_SSID "[Saputra]_plus"
#define WIFI_PASSWORD "qwerty33"
#define PIN_RELAY D2
#define PIN_LED_ONE D5


FirebaseData firebaseData;
bool alarmIsOn = false;
int alarmIsCounter = 0;
Neotimer neoTimer = Neotimer();

// Define NTP Client to get time
const long utcOffsetInSeconds = 3600*7; // Time offset GMT+7 in UTC
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "id.pool.ntp.org", utcOffsetInSeconds);

void setup() {
  Serial.begin(9600);

  //PIN MODES
  pinMode(PIN_RELAY, OUTPUT);
  pinMode(PIN_LED_ONE, OUTPUT);

  //turn off relay on first startup.
  digitalWrite(PIN_RELAY, HIGH);

  //Set timer 60 second to update device status
  neoTimer.set(60000);
  
  delay(10);

  //Initiate Wifi
  wifiInitialization();

  //Get NTP time
  timeClient.begin();

  //Initiate Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  //Firebase set alarm off on alarm startup;
  Firebase.setBool(firebaseData, "doorbell/isOn", false);

  //execute LastOnline in device startup
  timeClient.update();
  Firebase.setInt(firebaseData, "doorbell/lastOnline", timeClient.getEpochTime());

}

void loop() {
    
    timeClient.update();
  
//  Serial.print("ntp: ");
//  Serial.print(timeClient.getHours());
//  Serial.print(":");
//  Serial.print(timeClient.getMinutes());
//  Serial.print(":");
//  Serial.print(timeClient.getSeconds());
//  Serial.print("  ");
//  Serial.println(timeClient.getDay());
//  //GET epoch time
//  Serial.print("Epoch Time: ");
//  Serial.println(timeClient.getEpochTime());


   Firebase.getBool(firebaseData, "doorbell/isOn");
   alarmIsOn = firebaseData.boolData();
   
   Serial.println(alarmIsOn); 

   if(alarmIsOn){

    //Limit alarm to ring then reset ...
    if(alarmIsCounter<=10){
      alarmIsCounter++;
      digitalWrite(PIN_RELAY, LOW);
      digitalWrite(PIN_LED_ONE, HIGH);
    }else{
      digitalWrite(PIN_RELAY, HIGH);
      digitalWrite(PIN_LED_ONE, LOW);
      Firebase.setBool(firebaseData, "doorbell/isOn", false);
    }
    
   }else{
    digitalWrite(PIN_RELAY, HIGH);
    digitalWrite(PIN_LED_ONE, LOW);
    alarmIsCounter=0;
   }

   Serial.print("alarm counter limit: ");
   Serial.println(alarmIsCounter);

   //Inform device last online every 60 second
   if(neoTimer.repeat()){
    Firebase.setInt(firebaseData, "doorbell/lastOnline", timeClient.getEpochTime());
   }
   
   delay(30);

}

void wifiInitialization(){
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");  
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

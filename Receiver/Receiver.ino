#include <ESP8266WiFi.h>
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
#define PIN_BUZZER D8

FirebaseData firebaseData;
bool alarmIsOn = false;

void setup() {
  Serial.begin(9600);
  delay(10);

  //Initiate Wifi
  wifiInitialization();

  //Initiate Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

}

void loop() {

   Firebase.getBool(firebaseData, "doorbell/isOn");
   alarmIsOn =firebaseData.boolData();
   Serial.println(alarmIsOn); 

    if(alarmIsOn){
      tone(PIN_BUZZER, 1000);
    }else{
      noTone(PIN_BUZZER);
    }
   
   delay(50);

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

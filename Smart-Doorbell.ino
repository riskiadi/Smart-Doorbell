#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h>
#include <FirebaseESP8266.h>
#include <ESP8266HTTPClient.h>
#include "Neotimer.h"
#include "PinDefine.h"
#include <NTPClient.h>
#include <time.h>
#include <WiFiUdp.h>

//Define
#define FIREBASE_HOST "manyaran-sistem.firebaseio.com"
#define FIREBASE_AUTH "vGw7kpq6yTrIjPLVVciDBpqMoZxAkmaERSVRqZWt"
#define WIFI_SSID "[Saputra]_plus"
#define WIFI_PASSWORD "qwerty33"
#define PIN_TOUCH D6

BearSSL::WiFiClientSecure client;
HTTPClient http;
FirebaseData firebaseData;
FirebaseJson json;
time_t rawtime;
struct tm * ti;
Neotimer neoTimer = Neotimer(8000); // timer set push button every 4 second

// Define NTP Client to get time
const long utcOffsetInSeconds = -18; // Time offset GMT+7 in UTC 3600 = 1 hour
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "id.pool.ntp.org", utcOffsetInSeconds);

int httpCode = 0;
int fcmHttpCode = 0;
bool isSend = false;

void setup() {
  Serial.begin(9600);
  delay(10);

  //Initiate Wifi
  wifiInitialization();

  //Initiate Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  //Get NTP time
  timeClient.begin();
  
  //fcm client
  client.setInsecure();
  client.setTimeout(10000);
  client.connect("fcm.googleapis.com", 443); 

  neoTimer.start();

  //send First device startup time
  timeClient.update();
  Firebase.setInt(firebaseData, "bellbutton/firstBoot", timeClient.getEpochTime());
  
}

void loop() {

  timeClient.update();
  Serial.println(digitalRead(PIN_TOUCH));
  if(digitalRead(PIN_TOUCH) == 1){
    if(neoTimer.done()){
      Firebase.setBool(firebaseData, "doorbell/isOn", true);
      sendNotification();
      neoTimer.stop();
      neoTimer.start();
    }
  }
  
  delay(50);
  
}



void sendNotification(){
 client.setInsecure();
 client.setTimeout(10000);
 client.connect("fcm.googleapis.com", 443); 
 if(!client.connected()) {
   Serial.println("Failed to connect using insecure client, check internet connection or try to use fingerprint..");
   client.setInsecure();
   client.setTimeout(10000);
   client.connect("fcm.googleapis.com", 443);
   sendNotification();
 }else{
  
    Serial.println("[Success to connect]");
    Serial.println("--------");
    Serial.print("Sending post request...");
    http.begin(client,"https://fcm.googleapis.com/fcm/send");
    http.addHeader("User-Agent", "PostmanRuntime/7.26.5");
    http.addHeader("Connection", "keep-alive");
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", "key=AAAAAs30-qE:APA91bH2N8b_Lfp7B4aKMbKwPFedzwVWP3ffe_gPbwLdIE4jStahP5dQZ3AuVRnoGum-1LU8iWQZ8gT5DnkGYKL66LBN3w7nMYZYOwSiaa7IQZEEDWV64HTmnctWPzBvzne3gYmcWunn");
    fcmHttpCode = http.POST("{ \"to\":\"/topics/Doorbell\", \"priority\" : \"high\", \"notification\":{ \"title\":\"Manyaran Sistem\", \"body\":\"Seseorang mengunjungi rumah anda.\", \"sound\":\"notification.mp3\", \"android_channel_id\":\"manyaran_id\", \"tag\": \"tag1\", \"click_action\":\"FLUTTER_NOTIFICATION_CLICK\" } }");
    Serial.print("Post request completed, ");
    Serial.print("status code: ");
    Serial.println(fcmHttpCode);
    Serial.println("--------");
    
    //Send visitor history
    rawtime = timeClient.getEpochTime();
    ti = localtime (&rawtime);
    int month = (ti->tm_mon + 1) < 10 ? 0 + (ti->tm_mon + 1) : (ti->tm_mon + 1);
    String monthString = "";
    if(month<10){
      monthString = "0" + (String)month;
    }else{
      monthString = (String)month;
    }
    int year = ti->tm_year + 1900;
    json.set("date", (int)timeClient.getEpochTime());
    Firebase.pushJSON(firebaseData, "visitors/" + (String)year + "/" + monthString , json);

    http.end();
    client.stop();
    
  }
  
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

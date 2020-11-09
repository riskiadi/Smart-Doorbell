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
#define PIN_TOUCH D0
#define PIN_LED D1


BearSSL::WiFiClientSecure client;
HTTPClient http;
FirebaseData firebaseData;
FirebaseJson json;
time_t rawtime;
struct tm * ti;
Neotimer neoTimer = Neotimer(15000); // timer send notif delay 15 second
Neotimer neoTimer2 = Neotimer(6000); // timer set push button every 6 second

// Define NTP Client to get time
const long utcOffsetInSeconds = 0; // Time offset GMT+7 in UTC 3600 = 1 hour
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

  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, HIGH);

  neoTimer.start();
  neoTimer2.start();

  //send First device startup time
  timeClient.update();
  Firebase.setInt(firebaseData, "bellbutton/firstBoot", timeClient.getEpochTime());
  
}

void loop() {

  //update epoch time
  timeClient.update();

  Serial.println(digitalRead(PIN_TOUCH));
  if(digitalRead(PIN_TOUCH) == 1){
    if(neoTimer2.done()){
      if(!isSend){
        isSend = true;
        Firebase.setBool(firebaseData, "doorbell/isOn", true);
      }
      neoTimer2.stop();
      neoTimer2.start();
    }
  }else{
    if(isSend){
      isSend = false;
      if(neoTimer.done()){
        neoTimer.stop();
        sendNotification();
      }
    }
  }
  
  delay(10);
  
}



void sendNotification(){
 if(!client.connected()) {
    Serial.println("Failed to connect using insecure client, check internet connection or try to use fingerprint..");
   client.setInsecure();
   client.setTimeout(10000);
   client.connect("fcm.googleapis.com", 443);
   sendNotification();
 }else{
    Serial.println("[Success to connect]");
    Serial.println("--------");
    Serial.print("Sending post request to: ");
    Serial.println("https://fcm.googleapis.com/fcm/send");
    http.begin(client,"https://fcm.googleapis.com/fcm/send");
    http.addHeader("User-Agent", "PostmanRuntime/7.26.5");
    http.addHeader("Connection", "keep-alive");
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", "key=AAAAAs30-qE:APA91bH2N8b_Lfp7B4aKMbKwPFedzwVWP3ffe_gPbwLdIE4jStahP5dQZ3AuVRnoGum-1LU8iWQZ8gT5DnkGYKL66LBN3w7nMYZYOwSiaa7IQZEEDWV64HTmnctWPzBvzne3gYmcWunn");
    fcmHttpCode = http.POST("{ \"to\": \"/topics/Doorbell\", \"topic\": \"Doorbell\", \"notification\": { \"title\": \"MANYARAN SISTEM\", \"body\": \"Seseorang mengunjungi rumah anda.\", \"sound\": \"notification.mp3\", \"android_channel_id\" : \"manyaran_id\", \"click_action\" : \"FLUTTER_NOTIFICATION_CLICK\" } }");
    Serial.print("Post request completed, ");
    Serial.print("status code: ");
    Serial.println(fcmHttpCode);
    Serial.println("--------");
    
    //Send visitor history
    rawtime = timeClient.getEpochTime();
    ti = localtime (&rawtime);
    int month = (ti->tm_mon + 1) < 10 ? 0 + (ti->tm_mon + 1) : (ti->tm_mon + 1);
    int year = ti->tm_year + 1900;
    json.set("date", (float)timeClient.getEpochTime());
    Firebase.pushJSON(firebaseData, "visitors/" + (String)year + "/" + (String)month , json);

    neoTimer.start();
    
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

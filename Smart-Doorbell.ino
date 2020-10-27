#include <ESP8266WiFi.h>
#include <FirebaseArduino.h>
#include <ESP8266HTTPClient.h>
#include "PinDefine.h"

#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h> 


//Define
#define FIREBASE_HOST "manyaran-sistem.firebaseio.com"
#define FIREBASE_AUTH "vGw7kpq6yTrIjPLVVciDBpqMoZxAkmaERSVRqZWt"
#define WIFI_SSID "[Saputra-Mobile]"
#define WIFI_PASSWORD "alkalynx"
#define PIN_BUZZER D6
#define PIN_TOUCH D8

int httpCode = 0;
int fcmHttpCode = 0;
BearSSL::WiFiClientSecure client;
HTTPClient http;

//SHA1 finger print of certificate use Firefox to view and copy
const char* fingerprint = "06 0C 93 F2 CA 99 33 1C 00 A2 2D FF 4C C1 1C 89 4E C2 2E 75";

int testCounter = 1;

void setup() {
  Serial.begin(9600);
  delay(10);

  //Initiate Wifi
  wifiInitialization();

  //Initiate Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  //  sendDataToFirebase();
  
}

void loop() {

//  Serial.println(digitalRead(PIN_TOUCH));
//  if(digitalRead(PIN_TOUCH) == 1){
//    Firebase.setBool("doorbell/isOn", true);
//  }else{
//    Firebase.setBool("doorbell/isOn", false);
//  }
//  delay(1);

  if(testCounter%2==0){
    Firebase.setBool("doorbell/isOn", false);
    sendNotification();
  }else{
    Firebase.setBool("doorbell/isOn", true);
    sendNotification();
  }
  testCounter++;
  delay(5000);
  //test aja hapus aja


}




void sendNotification(){

 client.setInsecure();
 client.setTimeout(15000);
 int retries = 6;
 while(!client.connect("fcm.googleapis.com", 443) && (retries-- > 0)) {
   Serial.print(".");
   delay(1000);
 }
 Serial.println();
 if(!client.connected()) {
    Serial.println("Failed to connect using insecure client, try to use fingerprint.. going back to sleep.");
    client.stop();
    return;
 }else{
    Serial.println("Success to connect.");
    Serial.println("--------");
    Serial.print("Sending post request to: ");
    Serial.println("https://fcm.googleapis.com/fcm/send");
    http.begin(client,"https://fcm.googleapis.com/fcm/send");
    http.addHeader("User-Agent", "PostmanRuntime/7.26.5");
    http.addHeader("Connection", "keep-alive");
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", "key=AAAAWKZPac8:APA91bEZuPi9ZsYT7uQtXEQVpdTMSAfsEZVkZiXJ4i_yM6mxBeGD12i6oM-hWZvN01MsiInMpyFUiVbJCUJWPAKjagyev4sdw6mBAGe0LU0Yr4y2jAZ6ulc_xaXkaveBx5MEdqQdDPUK");
    fcmHttpCode = http.POST("{\"to\": \"/topics/beritaku\", \"topic\": \"beritaku\", \"notification\": { \"title\": \"Breaking News\", \"body\": \"New news available.\", \"sound\": \"default\"}}");
    Serial.print("Post request completed, ");
    Serial.print("status code: ");
    Serial.println(fcmHttpCode);
    http.end();
    Serial.println("--------");
 }

  client.stop();
 
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

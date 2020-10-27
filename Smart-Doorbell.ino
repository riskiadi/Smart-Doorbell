#include <ESP8266WiFi.h>
#include <FirebaseArduino.h>
#include <ESP8266HTTPClient.h>
#include "Neotimer.h"
#include "PinDefine.h"

#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h> 


//Define
#define FIREBASE_HOST "manyaran-sistem.firebaseio.com"
#define FIREBASE_AUTH "vGw7kpq6yTrIjPLVVciDBpqMoZxAkmaERSVRqZWt"
#define WIFI_SSID "[Saputra]_plus"
#define WIFI_PASSWORD "qwerty33"
#define PIN_BUZZER D6
#define PIN_TOUCH D8

int httpCode = 0;
int fcmHttpCode = 0;
BearSSL::WiFiClientSecure client;
HTTPClient http;
Neotimer notificationDelay;

void setup() {
  Serial.begin(9600);
  delay(10);
  notificationDelay.set(4000);

  //Initiate Wifi
  wifiInitialization();

  //Initiate Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  
}

void loop() {

  Serial.println(digitalRead(PIN_TOUCH));
  if(digitalRead(PIN_TOUCH) == 1){
    Firebase.setBool("doorbell/isOn", true);
    if(notificationDelay.repeat()){
      sendNotification();
    }
  }else{
    Firebase.setBool("doorbell/isOn", false);
  }
  delay(10);
  
}




void sendNotification(){

 client.setInsecure();
 client.setTimeout(15000);
 client.connect("fcm.googleapis.com", 443); 
 //Uncoment for can retry if failed to connect
// int retries = 6;
// while(!client.connect("fcm.googleapis.com", 443) && (retries-- > 0)) {
//   Serial.print(".");
//   delay(1000);
// }
 if(!client.connected()) {
    Serial.println("Failed to connect using insecure client, check internet connection or try to use fingerprint..");
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

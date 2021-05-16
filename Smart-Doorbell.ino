#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h>
#include <FirebaseESP8266.h>
#include <ESP8266HTTPClient.h>
#include "Neotimer.h"
#include <NTPClient.h>
#include <time.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <WiFiManager.h> // https://github.com/tzapu/WiFiManager
#include <TelnetSpy.h>  //external library https://github.com/yasheena/telnetspy

//Define
#define SERIAL  SerialAndTelnet
#define TRIGGER_PIN 0 //NODEMCU FLASH BUTTON RESET WIFI AUTH
#define FIREBASE_HOST "manyaran-sistem.firebaseio.com"
#define FIREBASE_AUTH "vGw7kpq6yTrIjPLVVciDBpqMoZxAkmaERSVRqZWt"
#define PIN_TOUCH 12

WiFiManager wm;
TelnetSpy SerialAndTelnet;
BearSSL::WiFiClientSecure client;
HTTPClient http;
FirebaseData firebaseData;
FirebaseJson json;
time_t rawtime;
struct tm * ti;
Neotimer neoTimer = Neotimer(6000); // timer set push button every 4 second

// Define NTP Client to get time
const long utcOffsetInSeconds = -18; // Time offset GMT+7 in UTC 3600 = 1 hour
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "id.pool.ntp.org", utcOffsetInSeconds);

int httpCode = 0;
int fcmHttpCode = 0;
bool isSend = false;

void setup() {
  
  pinMode(TRIGGER_PIN, INPUT);

  //Initiate Setup
  setupInitialization();

  //Initiate Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  //Get NTP time
  timeClient.begin();
  
  //fcm client
  client.setInsecure();
  client.setTimeout(10000);
  client.connect("fcm.googleapis.com", 443);  

  neoTimer.start();
  firebaseData.setResponseSize(1024);

  //send First device startup time
  timeClient.update();
  Firebase.setInt(firebaseData, "bellbutton/firstBoot", timeClient.getEpochTime());
  
}

void loop() {
  SerialAndTelnet.handle();
  ArduinoOTA.handle();
  checkButton();
  telnetCommandListener();

  timeClient.update();
  
  //Serial.println(digitalRead(PIN_TOUCH));
  if(digitalRead(PIN_TOUCH) == 1){
    if(neoTimer.done()){
      Firebase.setBool(firebaseData, "doorbell/isOn", true);
      sendNotification();
      neoTimer.stop();
      neoTimer.start();
    }
  }

  delay(30);
  
}



void sendNotification(){
 client.setInsecure();
 client.setTimeout(10000);
 client.connect("fcm.googleapis.com", 443); 
 if(!client.connected()) {
   Serial.println("Failed to connect using insecure client, check internet connection or try to use fingerprint..");
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

void setupInitialization(){
  SERIAL.begin(9600);
  WiFi.mode(WIFI_STA);
  std::vector<const char *> menu = {"wifi","sep","restart"};
  wm.setMenu(menu);
  wm.setClass("invert"); // set dark theme
  wm.setConnectTimeout(30); // how long to try to connect for before continuing
  wm.setConfigPortalTimeout(40);
  bool res;
  res = wm.autoConnect(); // auto generated AP name from chipid
  if(!res) {
    SERIAL.println("Failed to connect or hit timeout");
    ESP.restart();
  } 
  else {
    OTASetup();
    telnetSetup();
  }
}

void OTASetup(){
  ArduinoOTA.onStart([]() {
      String type;
      if (ArduinoOTA.getCommand() == U_FLASH) {
        type = "sketch";
      } else { // U_FS
        type = "filesystem";
      }
  
      // NOTE: if updating FS this would be the place to unmount FS using FS.end()
      SERIAL.println("Start updating " + type);
    });
    ArduinoOTA.onEnd([]() {
      SERIAL.println("\nEnd");
    });
    ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
      SERIAL.printf("Progress: %u%%\r", (progress / (total / 100)));
    });
    ArduinoOTA.onError([](ota_error_t error) {
      Serial.printf("Error[%u]: ", error);
      if (error == OTA_AUTH_ERROR) {
        SERIAL.println("Auth Failed");
      } else if (error == OTA_BEGIN_ERROR) {
        SERIAL.println("Begin Failed");
      } else if (error == OTA_CONNECT_ERROR) {
        SERIAL.println("Connect Failed");
      } else if (error == OTA_RECEIVE_ERROR) {
        SERIAL.println("Receive Failed");
      } else if (error == OTA_END_ERROR) {
        SERIAL.println("End Failed");
      }
    });
    ArduinoOTA.begin();
}

void telnetSetup(){
  SerialAndTelnet.setWelcomeMsg("Welcome to the ESP via TelnetSpy\n");
  SerialAndTelnet.setCallbackOnConnect(telnetConnected);
  delay(100); // Wait for serial port
  SERIAL.setDebugOutput(false);
}

void checkButton(){
  if ( digitalRead(TRIGGER_PIN) == LOW ) {
    // poor mans debounce/press-hold, code not ideal for production
    delay(50);
    if( digitalRead(TRIGGER_PIN) == LOW ){
      Serial.println("Button Pressed");
      // still holding button for 3000 ms, reset settings, code not ideaa for production
      delay(3000); // reset delay hold
      if( digitalRead(TRIGGER_PIN) == LOW ){
        Serial.println("Button Held");
        Serial.println("Erasing Config, restarting");
        wm.resetSettings();
        ESP.restart();
      }
    }
  }
}

void telnetConnected() {
  SERIAL.println("");
  SERIAL.println("Telnet connection established.");
  SERIAL.print("IP: ");
  SERIAL.println(WiFi.localIP());
  SERIAL.println("\nAvailable Commands:");
  SERIAL.println("Type 'r' for WiFi reconnect.");
  SERIAL.println("Type 'e' for ESP restart.");
  SERIAL.println("Type 'z' for Wifi restart setting config.");
  SERIAL.println("");
}

void telnetCommandListener(){
  if (SERIAL.available() > 0) {
    char c = SERIAL.read();
    switch (c) {
      case '\r':
        SERIAL.println();
        break;
      case 'r':
        SERIAL.print("\nReconnecting ");
        WiFi.reconnect();
        while (WiFi.status() == WL_CONNECTED) {
          delay(500);
          SERIAL.print(".");
        }
        SERIAL.println(" Disconnected!");
        while (WiFi.status() != WL_CONNECTED) {
          delay(500);
          SERIAL.print(".");
        }
        SERIAL.println(" Connected!");
        break;
      case 'e':
        SERIAL.println("Esp restart");
        ESP.restart();
        break;
      case 'z':
        SERIAL.println("Wifi Reset Setting");
        wm.resetSettings();
        ESP.restart();
        break;
      default:
        SERIAL.print(c);
        break;
    }
  }  
}

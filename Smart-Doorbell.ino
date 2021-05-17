#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266WiFiMulti.h>
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
#define FIREBASE_FCM_SERVER_KEY "AAAAAs30-qE:APA91bH2N8b_Lfp7B4aKMbKwPFedzwVWP3ffe_gPbwLdIE4jStahP5dQZ3AuVRnoGum-1LU8iWQZ8gT5DnkGYKL66LBN3w7nMYZYOwSiaa7IQZEEDWV64HTmnctWPzBvzne3gYmcWunn"
#define PIN_TOUCH 12

WiFiManager wm;
TelnetSpy SerialAndTelnet;
FirebaseData firebaseData;
FirebaseJson json;
time_t rawtime;
struct tm * ti;
Neotimer neoTimer = Neotimer(6000); // timer set push button every 4 second

// Define NTP Client to get time
const long utcOffsetInSeconds = 3600*7; // Time offset GMT+7 in UTC 3600 = 1 hour
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "id.pool.ntp.org", utcOffsetInSeconds, 60000);

void setup() {
  
  pinMode(TRIGGER_PIN, INPUT);

  //Initiate Setup
  setupInitialization();

  //Initiate Firebase Features
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  firebaseData.setBSSLBufferSize(1024, 1024);
  firebaseData.setResponseSize(1024);
  firebaseData.fcm.begin(FIREBASE_FCM_SERVER_KEY);
  firebaseData.fcm.setPriority("high");
  firebaseData.fcm.setTopic("Doorbell");
  firebaseData.fcm.setTimeToLive(5000);

  //Get NTP time
  timeClient.begin();
  timeClient.update();
  
  neoTimer.start();

  //send First device startup time
  Firebase.setInt(firebaseData, "bellbutton/firstBoot", timeClient.getEpochTime());
  
}

void loop() {
  SerialAndTelnet.handle();
  ArduinoOTA.handle();
  checkButton();
  telnetCommandListener();

  timeClient.update();
  
  if(digitalRead(PIN_TOUCH) == 1){
    if(neoTimer.done()){
      SERIAL.println("Sensor triggered.");
      firebasePush();
      sendNotification();
      neoTimer.stop();
      neoTimer.start();
    }
  }
  
}


void sendNotification(){
    firebaseData.fcm.addCustomNotifyMessage("title", "Manyaran Sistem");
    firebaseData.fcm.addCustomNotifyMessage("body", "Seseorang mengunjungi rumah anda (" + timeClient.getFormattedTime() + ").");
    firebaseData.fcm.addCustomNotifyMessage("sound", "notification.mp3");
    firebaseData.fcm.addCustomNotifyMessage("android_channel_id", "manyaran_id");
    firebaseData.fcm.addCustomNotifyMessage("tag", "tag1");
    firebaseData.fcm.addCustomNotifyMessage("click_action", "FLUTTER_NOTIFICATION_CLICK");
    SERIAL.println("------------------------------------");
    SERIAL.println("Send Firebase Cloud Messaging...");
    if (Firebase.sendTopic(firebaseData)){
        SERIAL.println("NOTIFICATION PASSED");
        SERIAL.println(firebaseData.fcm.getSendResult());
        SERIAL.println("------------------------------------");
        SERIAL.println();
    }else{
        SERIAL.println("NOTIFICATION FAILED");
        SERIAL.println("REASON: " + firebaseData.errorReason());
        SERIAL.println("------------------------------------");
        SERIAL.println();
     }
}

void firebasePush(){
  SERIAL.println("Firebase push visitor data\n");
  Firebase.setBool(firebaseData, "doorbell/isOn", true);

  unsigned long epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime ((time_t *)&epochTime);
  String currentMonth = "";
  int monthInt = ptm->tm_mon+1;
  int currentYear = ptm->tm_year+1900;
  if(monthInt<10){
    currentMonth = "0" + (String)monthInt;
  }else{
    currentMonth = (String)monthInt;
  }
  
  json.set("date", (int)timeClient.getEpochTime());
  Firebase.pushJSON(firebaseData, "visitors/" + (String)currentYear + "/" + currentMonth , json);
}

void setupInitialization(){
  SERIAL.begin(9600);
  WiFi.mode(WIFI_STA);
  std::vector<const char *> menu = {"wifi","sep","restart"};
  wm.setMenu(menu);
  wm.setClass("invert"); // set dark theme
  wm.setConnectTimeout(30); // how long to try to connect for before continuing
  wm.setConfigPortalTimeout(20);
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

void wifiScanner(){
  int n = WiFi.scanNetworks();
  if (n == 0) {
    SERIAL.println("no networks found");
  } else {
    SERIAL.print("\n[");
    SERIAL.print(n);
    SERIAL.println(" networks found]\n");
    for (int i = 0; i < n; ++i) {
      SERIAL.print(i + 1);
      SERIAL.print(") ");
      SERIAL.print(WiFi.SSID(i) + " ");
      SERIAL.print(WiFi.RSSI(i));
      SERIAL.print("dBm (");
      SERIAL.print(dBmtoPercentage(WiFi.RSSI(i)));//Signal strength in %  
      SERIAL.println("%)"); 
      delay(10);
    }
  }
  SERIAL.println("");
  delay(5000);
  WiFi.scanDelete();
}

int dBmtoPercentage(int dBm){
  int quality;
  if(dBm <= -100){
    quality = 0;
  }else if(dBm >= -50){ 
    quality = 100;
  }else{
  quality = 2 * (dBm + 100);
  }
  return quality;
}

void telnetConnected() {
  SERIAL.println("");
  SERIAL.println("Telnet connection established.");
  SERIAL.print("IP: ");
  SERIAL.println(WiFi.localIP());
  SERIAL.println("\nAvailable Commands:");
  SERIAL.println("Type 'e' for ESP restart.");
  SERIAL.println("Type 's' for Wifi scan network.");
  SERIAL.println("Type 'r' for WiFi reconnect.");
  SERIAL.println("Type 'z' for Wifi restart setting config.");
  SERIAL.println("Type 't' for Doorbell testing all.");
  SERIAL.println("Type 'h' for Doorbell testing only ring.");
  SERIAL.println("Type 'n' for Doorbell testing only notification.");
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
        ESP.restart();
        break;
      case 'z':
        wm.resetSettings();
        ESP.restart();
        break;
      case 't':
        firebasePush();
        sendNotification();
        break;
      case 'h':
        firebasePush();
        break;
      case 'n':
        sendNotification();
        break;
      case 's':
        wifiScanner();
        break;
      default:
        SERIAL.print(c);
        break;
    }
  }  
}

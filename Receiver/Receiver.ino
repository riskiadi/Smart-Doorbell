#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266WiFiMulti.h>
#include <FirebaseESP8266.h>
#include <ESP8266HTTPClient.h>
#include <NTPClient.h>
#include <time.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <WiFiManager.h> // https://github.com/tzapu/WiFiManager
#include <TelnetSpy.h>  //external library https://github.com/yasheena/telnetspy

//Define
#define SERIAL  SerialAndTelnet
#define FIREBASE_HOST "manyaran-sistem.firebaseio.com"
#define FIREBASE_AUTH "vGw7kpq6yTrIjPLVVciDBpqMoZxAkmaERSVRqZWt"
#define PIN_RELAY D2
#define PIN_LED_ONE D5

//variables
IPAddress ip;
bool alarmIsOn = false;
WiFiManager wm;
TelnetSpy SerialAndTelnet;
FirebaseData firebaseData;
FirebaseJson json;

// Define NTP Client to get time
const long utcOffsetInSeconds = 3600*7; // Time offset GMT+7 in UTC 3600 = 1 hour
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "id.pool.ntp.org", utcOffsetInSeconds, 60000);

void setup() {
  
  //PIN MODES
  pinMode(PIN_RELAY, OUTPUT);
  pinMode(PIN_LED_ONE, OUTPUT);
  
  //turn off relay on first startup.
  digitalWrite(PIN_RELAY, HIGH); // Relay OFF

  //Initiate Setup
  setupInitialization();

  //Initiate Firebase Features
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
  firebaseData.setBSSLBufferSize(1024, 1024);
  firebaseData.setResponseSize(1024);

  //Get NTP time
  timeClient.begin();
  timeClient.update();

  // check booting status
  ip = WiFi.localIP();
  Firebase.setInt(firebaseData, "doorbell/firstBoot", timeClient.getEpochTime());
  Firebase.setString(firebaseData, "doorbell/IPAddress", ip.toString().c_str());
  Firebase.setBool(firebaseData, "doorbell/isOn", false);

}

void loop() {
  SerialAndTelnet.handle();
  ArduinoOTA.handle();
  telnetCommandListener();
  timeClient.update();
  checkBell();
  delay(50);
}

void setupInitialization(){
  SERIAL.begin(9600);
  WiFi.mode(WIFI_STA);
  std::vector<const char *> menu = {"wifi","sep","restart"};
  wm.setMenu(menu);
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

void checkBell(){
  Firebase.getBool(firebaseData, "doorbell/isOn");
  alarmIsOn = firebaseData.boolData();
  if(alarmIsOn){ 
    digitalWrite(PIN_LED_ONE, HIGH);
    digitalWrite(PIN_RELAY, LOW); // ON
    delay(700);
    digitalWrite(PIN_RELAY, HIGH); // OFF
    digitalWrite(PIN_LED_ONE, LOW);
    Firebase.setBool(firebaseData, "doorbell/isOn", false);
  }else{
    digitalWrite(PIN_RELAY, HIGH);
    digitalWrite(PIN_LED_ONE, LOW);
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

void reconnectWifi(){
  SERIAL.println("\nReconnecting");
  WiFi.reconnect();
  while (WiFi.status() == WL_CONNECTED) {
    delay(500);
    SERIAL.print(".");
  }
  SERIAL.println("\nDisconnected!");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    SERIAL.print(".");
  }
  SERIAL.println("\nConnected!");
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
  SERIAL.println(ip);
  SERIAL.println("\nAvailable Commands:");
  SERIAL.println("Type 'h' for help.");
  SERIAL.println("Type 'e' for ESP restart.");
  SERIAL.println("Type 's' for Wifi scan network.");
  SERIAL.println("Type 'r' for WiFi reconnect.");
  SERIAL.println("Type 'z' for Wifi restart configuration.");
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
        reconnectWifi();
        break;
      case 'h':
        telnetConnected();
        break;
      case 'e':
        ESP.restart();
        break;
      case 'z':
        wm.resetSettings();
        ESP.restart();
        break;
      case 's':
        wifiScanner();
        break;
      default:
        SERIAL.println(c);
        break;
    }
  }  
}

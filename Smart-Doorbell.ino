#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h>
#include <ESP8266HTTPClient.h>
#include "Neotimer.h"
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <WiFiManager.h> // https://github.com/tzapu/WiFiManager
#include <TelnetSpy.h>  //external library https://github.com/yasheena/telnetspy

//Define

#define SERVER_IP "http://192.168.100.200/fcm_send/"

#define SERIAL  SerialAndTelnet
#define TRIGGER_PIN 0 //NODEMCU FLASH BUTTON RESET WIFI AUTH
#define PIN_TOUCH 12

//variables
bool disableDoorbell = false;
IPAddress ip;
WiFiManager wm;
TelnetSpy SerialAndTelnet;
struct tm * ti;
Neotimer neoTimer = Neotimer(5000); // timer set push button every 4 second

void setup() {
  
  pinMode(TRIGGER_PIN, INPUT);

  //Initiate Setup
  setupInitialization();
  
  neoTimer.start();

  // check booting status IP
  ip = WiFi.localIP();

}

void loop() {
  SerialAndTelnet.handle();
  ArduinoOTA.handle();
  checkButton();
  telnetCommandListener();

  if(digitalRead(PIN_TOUCH) == 1){
    if(neoTimer.done()){
      SERIAL.println("Sensor triggered.");
      runFCM();
      neoTimer.stop();
      neoTimer.start();
    }
  }
  
}

void runFCM(){
  WiFiClient client;
  HTTPClient http;
  http.begin(SERVER_IP);
  http.addHeader("Connection", "keep-alive");
  http.addHeader("secret", "riskiadi");
  http.GET();
  http.end();
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
  SerialAndTelnet.setWelcomeMsg("Welcome to the [Doorbell ESP] via TelnetSpy\n");
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
  SERIAL.println(WiFi.localIP());
  SERIAL.println("\nAvailable Commands:");
  SERIAL.println("Type 'h' for help.");
  SERIAL.println("Type 'e' for ESP restart.");
  SERIAL.println("Type 's' for Wifi scan network.");
  SERIAL.println("Type 'r' for WiFi reconnect.");
  SERIAL.println("Type 'z' for Wifi restart configuration.");
  SERIAL.println("Type 't' for Doorbell testing all.");
  SERIAL.println("Type 'd' for Doorbell disable.");
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
      case 't':
        runFCM();
        break;
      case 'd':
        disableDoorbell = !disableDoorbell;
        SERIAL.print("Doorbell disable = ");
        SERIAL.println(disableDoorbell ? "true" : "false");
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

#include <WiFi.h>
#include <ArduinoOSC.h>
#include <Adafruit_NeoPixel.h>

#define PIN         22
#define PIXEL_COUNT 8
#define FRAME_CACHE_SIZE 100

int frames[FRAME_CACHE_SIZE][PIXEL_COUNT][3];

int frameWriteIndex = 0;
int frameReadIndex = 0;

Adafruit_NeoPixel pixels(PIXEL_COUNT, PIN, NEO_GRB + NEO_KHZ800);

const String ssid = "TotallyNotSkynet";
const String password = "CabinetPolicySkipFir3$";

const int WIFI_TIMEOUT = 5000;
bool connected = false;

void setup() {
  Serial.begin(115400);
  pixels.begin();
  pixels.clear();
  startWiFi();
  attachOscListener();
}

int frameStarted = millis();
bool started = false;

void loop() {
  if ( connected ) OscWiFi.update();

  if ( millis() - frameStarted >= 100 ) {
    if ( started || frameWriteIndex++ >= 10 ) {
      started = true;
      if ( frameReadIndex++ >= FRAME_CACHE_SIZE ) {
        frameReadIndex = 0;
      }
      for ( int i = 0; i < PIXEL_COUNT; i++ ) {
        pixels.setPixelColor(i, pixels.Color(frames[frameReadIndex][i][0], frames[frameReadIndex][i][1], frames[frameReadIndex][i][2]));
      }
      pixels.show();
    }
    frameStarted = millis();
  }
//  delay(10);
}

void attachOscListener() {
  OscWiFi.subscribe(3333, "/data",
  [](const OscMessage & m) {
    String frame = m.arg<String>(0);
//    Serial.println(frame);
    saveFrame(frame);
//    pixels.clear();
//    int p = 0;
//    for ( int i = 0; i < (PIXEL_COUNT * 3); i += 3 ) {
//      int red = getValue(frame, ' ', i).toInt();
//      int green = getValue(frame, ' ', i+1).toInt();
//      int blue = getValue(frame, ' ', i+2).toInt();
//      pixels.setPixelColor(p++, pixels.Color(red, green, blue));
//    }
//    pixels.show();
  });
}

void saveFrame(String frameStr) {
  int p = 0;
  int frame[PIXEL_COUNT][3];
  for ( int i = 0; i < (PIXEL_COUNT * 3); i += 3 ) {
    int red = getValue(frameStr, ' ', i).toInt();
    int green = getValue(frameStr, ' ', i+1).toInt();
    int blue = getValue(frameStr, ' ', i+2).toInt();
    frames[frameWriteIndex][p][0] = red;
    frames[frameWriteIndex][p][1] = green;
    frames[frameWriteIndex][p][2] = blue;
  }
  if ( frameWriteIndex++ > FRAME_CACHE_SIZE ) {
    frameWriteIndex = 0;
  }
}

String getValue(String data, char separator, int index) {
  int found = 0;
  int strIndex[] = { 0, -1 };
  int maxIndex = data.length() - 1;

  for (int i = 0; i <= maxIndex && found <= index; i++) {
      if (data.charAt(i) == separator || i == maxIndex) {
          found++;
          strIndex[0] = strIndex[1] + 1;
          strIndex[1] = (i == maxIndex) ? i+1 : i;
      }
  }
  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
}

void startWiFi() {
  WiFi.disconnect(true);
  if ( ssid != "" && password != "" ) {
    Serial.println("Accessing WiFi: " + String(ssid));
    WiFi.begin(ssid.c_str(), password.c_str());
    int started = millis();
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      if ( (millis() - started) > WIFI_TIMEOUT ) {
        Serial.println("Cannot connect to WiFi");
        connected = false;
        return;
      }
    }
    connected = true;
    Serial.print("Connected on ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("No WiFi credentials");
    connected = false;
  }
}

void stopWiFi() {
  if ( connected ) {
    WiFi.disconnect(true);
    connected = false;
  }
}


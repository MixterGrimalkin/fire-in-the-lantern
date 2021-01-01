#include <WiFi.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include "FastLED.h"

const String ssid = "TotallyNotSkynet";
const String password = "CabinetPolicySkipFir3$";

const int WIFI_TIMEOUT = 5000;
bool connected = false;

AsyncWebServer server(80);

#define INNER_RING 0
#define OUTER_RING 1
#define TOP 2

#define RING_PIN  21
#define TOP_PIN   22

#define INNER_RING_SIZE 12
#define OUTER_RING_SIZE 24
#define RING_SIZE INNER_RING_SIZE+OUTER_RING_SIZE
#define TOP_SIZE  5
#define TOP_FUDGE_SIZE  10
#define PIXEL_COUNT RING_SIZE+TOP_SIZE

#define OFFSET_INNER_RING 1
#define OFFSET_OUTER_RING 10

CRGB neopixelRing[RING_SIZE];
CRGB neopixelTop[TOP_SIZE];

int lastRender;

struct Pixel {
  int region;
  int number;
  int colourForeground[3];
  int colourBackground[3];
  double amount;
  PixelData() {
    PixelData(0, 0);
  }
  PixelData(int r, int n) {
    region = r;
    number = n;
    setForeground(0, 0, 0);
    setBackground(0, 0, 0);
    amount = 0.0;
  }
  void set(int r, int g, int b) {
    setForeground(r, g, b);
    amount = 1.0;
  }
  void clear() {
    setBackground(0, 0, 0);
    amount = 0.0;
  }
  void setForeground(int r, int g, int b) {
    colourForeground[0] = r;
    colourForeground[1] = g;
    colourForeground[2] = b;
  }
  void setBackground(int r, int g, int b) {
    colourBackground[0] = r;
    colourBackground[1] = g;
    colourBackground[2] = b;
  }
  void setAmount(double a) {
    amount = a;
  }
  CRGB getColour() {
    return CRGB(mixComponent(0), mixComponent(1), mixComponent(2));
  }
  int mixComponent(int c) {
    return colourBackground[c] + ((colourForeground[c] - colourBackground[c]) * amount);
  }
};

struct Region {
  Pixel * pixels;
  int size;
  Region() {}
  Region(Pixel * p, int s) {
    pixels = p;
    size = s;
  }
};

Pixel pxTop[TOP_SIZE] ;
Pixel pxInner[INNER_RING_SIZE];
Pixel pxOuter[OUTER_RING_SIZE];

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println(" _,  _,____,____,        __,   ____,_,  _,____,____,____, _,  _,");
  Serial.println("(-|\\ |(-|_,(-/  \\  ____,(-|   (-/_|(-|\\ |(-|  (-|_,(-|__)(-|\\ | ");
  Serial.println(" _| \\|,_|__,_\\__/,(      _|__,_/  |,_| \\|,_|,  _|__,_|  \\,_| \\|,");
  Serial.println();

  initNeopixel();
  startWiFi();

  render();
}

void loop() {
  for ( int i = 0; i < 100; i++ ) {
    pxTop[position(TOP, i/100.0)].set(255, 0, 127);
    pxInner[position(INNER_RING, i/100.0)].set(0, 0, 127);
    pxOuter[position(OUTER_RING, i/100.0)].set(0, 50, 40);
    render();
    delay(10);
  }
  delay(50);
  for ( int i = 0; i < 100; i++ ) {
    int topIndex = (i/100.0)*TOP_SIZE;
    pxTop[position(TOP, i/100.0)].clear();
    pxInner[position(INNER_RING, i/100.0)].clear();
    pxOuter[position(OUTER_RING, i/100.0)].clear();
    render();
    delay(10);
  }
  delay(50);
}

void initNeopixel() {
  FastLED.addLeds<NEOPIXEL, TOP_PIN>(neopixelTop, TOP_FUDGE_SIZE);
  FastLED.addLeds<NEOPIXEL, RING_PIN>(neopixelRing, RING_SIZE);
  int i;
  for ( i=0; i<TOP_SIZE; i++ ) {
    pxTop[i] = Pixel(TOP, i);
  }
  for ( i=0; i<INNER_RING_SIZE; i++ ) {
    pxInner[i] = Pixel(INNER_RING, i);
  }
  for ( i=0; i<OUTER_RING_SIZE; i++ ) {
    pxOuter[i] = Pixel(OUTER_RING, i);
  }
}

void render() {
  int i;
  for ( i=0; i<TOP_SIZE; i++ ) {
    setPixel(pxTop[i].region, pxTop[i].number, pxTop[i].getColour());
  }
  for ( i=0; i<INNER_RING_SIZE; i++ ) {
    setPixel(pxInner[i].region, pxInner[i].number, pxInner[i].getColour());
  }
  for ( i=0; i<OUTER_RING_SIZE; i++ ) {
    setPixel(pxOuter[i].region, pxOuter[i].number, pxOuter[i].getColour());
  }
  FastLED.show();
  lastRender = millis();
}

void setPixel(int region, int pixelNo, CRGB colour) {
  int p;
  CRGB * neopixel;
  switch ( region ) {
    case INNER_RING:
      p = trim(((pixelNo + OFFSET_INNER_RING) % 12) + 24, 24, 35);
      neopixel = neopixelRing;
      break;
    case OUTER_RING:
      p = trim((pixelNo + OFFSET_OUTER_RING) % 24, 0, 23);
      neopixel = neopixelRing;
      break;
    case TOP:
      p = trim(pixelNo, 0, 6);
      neopixel = neopixelTop;
      break;
  }
  neopixel[p] = colour;
}


//////////
// WiFi //
//////////

void startWiFi() {
  WiFi.disconnect(true);
  if ( ssid != "" && password != "" ) {
    Serial.print(" WiFi: " + String(ssid) + " -- ");
    WiFi.begin(ssid.c_str(), password.c_str());
    int started = millis();
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      if ( (millis() - started) > WIFI_TIMEOUT ) {
        Serial.println("Failed");
        connected = false;
        return;
      }
    }
    connected = true;
    Serial.println(WiFi.localIP());
  } else {
    connected = false;
  }
}

void stopWiFi() {
  if ( connected ) {
    WiFi.disconnect(true);
    connected = false;
  }
}


/////////////
// Utility //
/////////////

int position(int region, double amount) {
  switch ( region ) {
    case INNER_RING:
      return floor(amount * INNER_RING_SIZE);
    case OUTER_RING:
      return floor(amount * OUTER_RING_SIZE);
    case TOP:
      return floor(amount * TOP_SIZE);
  }
}

int trim(int value, int min, int max) {
  if ( value > max ) {
    return max;
  } else if ( value < min ) {
    return min;
  } else {
    return value;
  }
}

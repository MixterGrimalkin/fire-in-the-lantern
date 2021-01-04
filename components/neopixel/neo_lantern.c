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

#define RED 0
#define GREEN 1
#define BLUE 2

struct Envelope {
  int preDelay = 0;
  double initialValue = 0.0;
  int attackTime = 0;
  double attackValue = 0.0;
  int decayTime = 0;
  int sustainTime = 0;
  double sustainValue = 0.0;
  int releaseTime = 0;
  double endValue = 0.0;

  int startedAt = -1;
  bool repeat = false;

  Envelope() {
  }

  void start() {
    startedAt = millis();
  }

  double getAmount() {
    if ( startedAt == -1 ) {
      return -1;
    }

    int elapsed = millis() - startedAt;

    if ( elapsed < preDelay ) {
      return initialValue;
    }

    elapsed -= preDelay;

    if ( elapsed < attackTime ) {
      return initialValue + ((attackValue - initialValue) * ((double)elapsed / (double)attackTime));
    }

    elapsed -= attackTime;

    if ( elapsed < decayTime ) {
      return attackValue + ((sustainValue - attackValue) * ((double)elapsed / (double)decayTime));
    }

    elapsed -= decayTime;

    if ( elapsed < sustainTime ) {
      return sustainValue;
    }

    elapsed -= sustainTime;

    if ( elapsed < releaseTime ) {
      return sustainValue + ((endValue - sustainValue) * ((double)elapsed / (double)sustainTime));
    }

    if ( repeat ) {
      startedAt = millis();
    }

    return endValue;
  }
};

struct Pixel {
  int region;
  int number;
  int colourForeground[3];
  int colourBackground[3];
  double amount;
  Envelope envelope = Envelope();
  Pixel() {
    Pixel(0, 0);
  }
  Pixel(int r, int n) {
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
    colourForeground[RED] = r;
    colourForeground[GREEN] = g;
    colourForeground[BLUE] = b;
  }
  void setBackground(int r, int g, int b) {
    colourBackground[RED] = r;
    colourBackground[GREEN] = g;
    colourBackground[BLUE] = b;
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

  void fadeEnvelope(int preDelay, double initialValue,
                int attackTime, double attackValue,
                int decayTime,
                int sustainTime, double sustainValue,
                int releaseTime, double endValue,
                bool repeat
  ) {
    envelope = Envelope();
    envelope.preDelay = preDelay;
    envelope.initialValue = initialValue;
    envelope.attackTime = attackTime;
    envelope.attackValue = attackValue;
    envelope.decayTime = decayTime;
    envelope.sustainTime = sustainTime;
    envelope.sustainValue = sustainValue;
    envelope.releaseTime = releaseTime;
    envelope.endValue = endValue;
    envelope.repeat = repeat;
    Serial.println(envelope.preDelay);
    envelope.start();
  }


  void fadeIn(int delayTime, int fadeInTime) {
    envelope = Envelope();
    envelope.initialValue = amount;
    envelope.preDelay = delayTime;
    envelope.attackTime = fadeInTime;
    envelope.attackValue = 1.0;
    envelope.endValue = 1.0;
    envelope.start();
  }

  void update() {
    double newAmount = envelope.getAmount();
    if (newAmount >= 0) amount = newAmount;
  }

};

Pixel allPixels[PIXEL_COUNT];
Pixel pxTop[TOP_SIZE] ;
Pixel pxInner[INNER_RING_SIZE];
Pixel pxOuter[OUTER_RING_SIZE];

void updatePixels() {
  int i;
  for ( i=0; i<TOP_SIZE; i++ ) {
    pxTop[i].update();
  }
  for ( i=0; i<INNER_RING_SIZE; i++ ) {
    pxInner[i].update();
  }
  for ( i=0; i<OUTER_RING_SIZE; i++ ) {
    pxOuter[i].update();
  }
}

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println(" _,  _,____,____,        __,   ____,_,  _,____,____,____, _,  _,");
  Serial.println("(-|\\ |(-|_,(-/  \\  ____,(-|   (-/_|(-|\\ |(-|  (-|_,(-|__)(-|\\ | ");
  Serial.println(" _| \\|,_|__,_\\__/,(      _|__,_/  |,_| \\|,_|,  _|__,_|  \\,_| \\|,");
  Serial.println();

  initNeopixel();
  startWiFi();


  waveringPattern(TOP,        127, 0, 255, 90, 0, 0);
  waveringPattern(INNER_RING, 127, 64, 0, 0, 90, 90);
  waveringPattern(OUTER_RING, 127, 90, 30, 0, 0, 0);

  render();
}



void waveringPattern(int region, int r1, int g1, int b1, int r2, int g2, int b2) {
  Pixel * pixels = getPixelSet(region);
  int pixelCount;
  switch ( region ) {
    case INNER_RING:
      pixels = pxInner;
      pixelCount = INNER_RING_SIZE;
      break;
    case OUTER_RING:
      pixels = pxOuter;
      pixelCount = OUTER_RING_SIZE;
      break;
    case TOP:
      pixels = pxTop;
      pixelCount = TOP_SIZE;
      break;
  }
  for ( int i=0; i<pixelCount; i++ ) {
    pixels[i].setForeground(r1, g1, b1);
    pixels[i].setBackground(r2, g2, b2);
    pixels[i].fadeEnvelope(abs(rand()) % 1000, 0.0, 1000, 1.0, 500, 2000, 0.7, 1000, 0.2, true);
  }
}

Pixel * getPixelSet(int region) {
  switch ( region ) {
    case INNER_RING:
      return pxInner;
    case OUTER_RING:
      return pxOuter;
    case TOP:
      return pxTop;
  }
}

int getPixelCount(int region) {
  switch ( region ) {
    case INNER_RING:
      return INNER_RING_SIZE;
    case OUTER_RING:
      return OUTER_RING_SIZE;
    case TOP:
      return TOP_SIZE;
  }
}


int framePeriod = 1.0 / 10;

void loop() {
  int now = millis();

  updatePixels();
  render();

  int elapsed = millis() - now;
  if ( elapsed < framePeriod ) {
    delay(framePeriod - elapsed);
  }

  delay(10);
}

void initNeopixel() {
  FastLED.addLeds<NEOPIXEL, TOP_PIN>(neopixelTop, TOP_FUDGE_SIZE);
  FastLED.addLeds<NEOPIXEL, RING_PIN>(neopixelRing, RING_SIZE);
  int i;
  int j = 0;
  for ( i=0; i<TOP_SIZE; i++ ) {
    pxTop[i] = Pixel(TOP, i);
//    allPixels[j++] = pxTop[i];
  }
  for ( i=0; i<INNER_RING_SIZE; i++ ) {
    pxInner[i] = Pixel(INNER_RING, i);
//    allPixels[j++] = pxInner[i];
  }
  for ( i=0; i<OUTER_RING_SIZE; i++ ) {
    pxOuter[i] = Pixel(OUTER_RING, i);
//    allPixels[j++] = pxOuter[i];
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

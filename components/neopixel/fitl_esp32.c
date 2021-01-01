#include <WiFi.h>
#include <ArduinoOSC.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

#include "FastLED.h"
#define FASTLED_ALLOW_INTERRUPTS 0

#define RING_PIN  21
#define TOP_PIN   22

#define RING_SIZE 36
#define TOP_SIZE  10  // Weird thing here ?

#define PIXEL_COUNT TOP_SIZE + RING_SIZE

CRGB neopixelRing[RING_SIZE];
CRGB neopixelTop[TOP_SIZE];

const String ssid = "TotallyNotSkynet";
const String password = "CabinetPolicySkipFir3$";

const int WIFI_TIMEOUT = 5000;
bool connected = false;

AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

static bool updating = false;
int frameStarted = millis();

struct Frame {
  int * data;
  Frame * next;
  Frame * prev;
  Frame(int * frameData) {
    data = frameData;
    next = prev = NULL;
  }
  void print() {
    Serial.print("[");
    for ( int i=0; i<(PIXEL_COUNT*3); i+=3 ) {
      Serial.print("(");
      Serial.print(data[i]);
      Serial.print(",");
      Serial.print(data[i+1]);
      Serial.print(",");
      Serial.print(data[i+2]);
      Serial.print(")");
    }
    Serial.println("]");
  }
};

struct Reel {
  Frame *first, *last, *next;
  int size;
  int frameMillis;
  Reel(int frameDurationMilliseconds) {
    first = last = next = NULL;
    size = 0;
    frameMillis = frameDurationMilliseconds;
  }
  void addFrame(int * frameData) {
    Frame * temp = new Frame(frameData);
    if ( first == NULL ) {
      first = last = temp;
    } else {
      last->next = temp;
      last = temp;
    }
    size++;
  }
  Frame * nextFrame() {
    Frame * temp = next;
    if ( temp==NULL ) {
      temp = first;
      next = first->next;
    } else {
      next = temp->next;
    }
    return temp;
  }
  void print() {
    Serial.println("-- REEL --");
    Frame * temp = first;
    while ( temp != NULL ) {
      temp->print();
      temp = temp->next;
    }
    Serial.println("----------");
  }
};

Reel * reel = new Reel(100);

void setup() {
  Serial.begin(115400);
  FastLED.addLeds<NEOPIXEL, TOP_PIN>(neopixelTop, TOP_SIZE);
  FastLED.addLeds<NEOPIXEL, RING_PIN>(neopixelRing, RING_SIZE);

  startWiFi();
  startWebSocket();

  FastLED.show();
  frameStarted = millis();
}

void loop() {
  if ( connected ) {
    ws.cleanupClients();
  }
  if ( updating ) {
    delay(reel->frameMillis);
  } else {
    if ( reel->size > 10 ) {
      int frameStarted = millis();

//      reel->nextFrame()->print();
      FastLED.show();
//      renderFrame(reel->nextFrame()->data);

      int elapsed = millis() - frameStarted;
      if ( elapsed < reel->frameMillis ) {
        delay(reel->frameMillis - elapsed);
      }
    } else {
      delay(reel->frameMillis);
    }
  }
}

void fill(int start, int size, CRGB colour) {
  for ( int i=start; i<(start+size); i++ ) {
    setPixel(i, colour);
  }
}

void setPixel(int pixel, CRGB colour) {
  if ( pixel >= RING_SIZE ) {
    neopixelTop[pixel - RING_SIZE] = colour;
  } else {
    neopixelRing[pixel] = colour;
  }
}


////////////
// Frames //
////////////

void renderFrame(int * frame) {
  int p = 0;
  for ( int i=0; i<PIXEL_COUNT*3; i+=3 ) {
    int red = frame[i];
    int green = frame[i+1];
    int blue = frame[i+2];
    setPixel(p++, CRGB(red, green, blue));
  }
//  delay(10);
//  FastLED.show();
//  delay(10);
}


int * parseFrame(char * string) {
  int counter=0;
  static int frame[PIXEL_COUNT * 3];

  char * component = strtok(string, " ");
  while ( component != NULL ) {
    frame[counter++] = atoi(component);
    component = strtok(NULL, " ");
  }

  while ( counter < PIXEL_COUNT ) {
    frame[counter++] = 0;
  }

  return frame;
}


///////////////
// WebSocket //
///////////////

void startWebSocket() {
  server.begin();
  ws.onEvent(onEvent);
  server.addHandler(&ws);
  Serial.println("WebSocket started");
}

void handleWebSocketMessage(void *arg, uint8_t *data, size_t len) {
  updating = true;
  AwsFrameInfo *info = (AwsFrameInfo*)arg;
  if (info->final && info->index == 0 && info->len == len && info->opcode == WS_TEXT) {
    data[len] = 0;
    Serial.println("hello");
    int * frame = parseFrame((char*)data);
    reel->addFrame(frame);
  }
  updating = false;
}

void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
      ws.textAll("Welcome!");
      break;
    case WS_EVT_DISCONNECT:
      Serial.printf("WebSocket client #%u disconnected\n", client->id());
      break;
    case WS_EVT_DATA:
      handleWebSocketMessage(arg, data, len);
      break;
    case WS_EVT_PONG:
    case WS_EVT_ERROR:
      break;
  }
}


//////////
// WiFi //
//////////

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
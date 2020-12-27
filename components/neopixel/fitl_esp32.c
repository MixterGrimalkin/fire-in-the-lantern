#include <WiFi.h>
#include <ArduinoOSC.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebServer.h>

#include "FastLED.h"

#define RING_PIN  21
#define TOP_PIN   22

#define RING_SIZE 36
#define TOP_SIZE  16  // Weird thing here ?

#define PIXEL_COUNT TOP_SIZE + RING_SIZE

#define FRAME_CACHE_SIZE 100

int frames[FRAME_CACHE_SIZE][PIXEL_COUNT][3];

int frameWriteIndex = 0;
int frameReadIndex = 0;

CRGB neopixelRing[RING_SIZE];
CRGB neopixelTop[TOP_SIZE];

// WiFi & WebSocket
const String ssid = "TotallyNotSkynet";
const String password = "CabinetPolicySkipFir3$";
const int WIFI_TIMEOUT = 5000;
bool connected = false;

AsyncWebServer server(80);
AsyncWebSocket ws("/ws");


struct QNode {
    String frame;
    QNode* next;
    QNode(String f) {
      frame = f;
      next = NULL;
    }
};

struct Queue {
    QNode *front, *rear;
    int size;
    Queue() {
      front = rear = NULL;
      size = 0;
    }
    void enQueue(String f) {
      size++;
      QNode* temp = new QNode(f);
      if (rear == NULL) {
          front = rear = temp;
          return;
      }
      rear->next = temp;
      rear = temp;
    }

    String deQueue() {
      size--;
      if (front == NULL)  return "";

      String frame = front->frame;

      QNode* temp = front;
      front = front->next;
      if (front == NULL) rear = NULL;
      delete (temp);

      return frame;
    }
};

Queue queue;


int frameStarted = millis();
bool started = false;

int pixelColours[PIXEL_COUNT][3];

int frameRate = 15;
int frameDuration = 1000 / frameRate;

static bool updating = false;


void setup() {
  Serial.begin(115400);
  FastLED.addLeds<NEOPIXEL, TOP_PIN>(neopixelTop, TOP_SIZE);
  FastLED.addLeds<NEOPIXEL, RING_PIN>(neopixelRing, RING_SIZE);

  startWiFi();
  startWebSocket();

//  attachOscListener();

  FastLED.show();
  frameStarted = millis();
}

void loop() {
  if ( connected ) {
    OscWiFi.update();
    ws.cleanupClients();
  }

  if ( queue.size > 10 ) {
    if ( millis() - frameStarted >= frameDuration ) {
      String frame = queue.deQueue();
      displayFrame(queue.deQueue());
      frameStarted = millis();
    }
  }

  if ( !updating && millis() - frameStarted > (1.0 / 16) ) {
    FastLED.show();
    frameStarted = millis();
  }
}

void attachOscListener() {
  OscWiFi.subscribe(3333, "/data",
  [](const OscMessage & m) {
    String frame = m.arg<String>(0);
    queue.enQueue(frame);
  });
}

void displayFrame(String frame) {
  Serial.println(frame);
  int p = 0;
  for ( int i = 0; i < (PIXEL_COUNT * 3); i += 3 ) {
    int red = getValue(frame, ' ', i).toInt();
    int green = getValue(frame, ' ', i+1).toInt();
    int blue = getValue(frame, ' ', i+2).toInt();
    if ( p >= RING_SIZE ) {
      neopixelTop[p - RING_SIZE] = CRGB(red, green, blue);
    } else {
      neopixelRing[p] = CRGB(red, green, blue);
    }
    p++;
  }
  FastLED.show();
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

    int * frame = parseFrame((char*)data);

    int p = 0;
    for ( int i=0; i<PIXEL_COUNT*3; i+=3 ) {
      int red = frame[i];
      int green = frame[i+1];
      int blue = frame[i+2];
      if ( p >= RING_SIZE ) {
        neopixelTop[p - RING_SIZE] = CRGB(red, green, blue);
      } else {
        neopixelRing[p] = CRGB(red, green, blue);
      }
      p++;
    }
  }
  updating = false;
}

int * parseFrame(char * string) {
  static int frame[PIXEL_COUNT * 3];

  char * pixel = strtok(string, " ");
  char * pixelStrings[PIXEL_COUNT];
  int p = 0;
  while (pixel != NULL && p < PIXEL_COUNT) {
    pixelStrings[p++] = pixel;
    pixel = strtok(NULL, " ");
  }

  int c = 0;
  for ( int i=0; i<p; i++ ) {
    if ( pixelStrings[i] != NULL ) {
      char * component = strtok(pixelStrings[i], ",");

      int red = -1;
      int green = -1;
      int blue = -1;
      int j = 0;
      while (component != NULL ) {
        if ( red < 0 ) {
          red = atoi(component);
        } else if ( green < 0 ) {
          green = atoi(component);
        } else if ( blue < 0 ) {
          blue = atoi(component);
        }
        component = strtok(NULL, ",");
      }
      frame[c++] = red;
      frame[c++] = green;
      frame[c++] = blue;
    }
  }
  return frame;
}

void onEvent(AsyncWebSocket *server, AsyncWebSocketClient *client, AwsEventType type, void *arg, uint8_t *data, size_t len) {
  switch (type) {
    case WS_EVT_CONNECT:
      Serial.printf("WebSocket client #%u connected from %s\n", client->id(), client->remoteIP().toString().c_str());
//      String reply = "Welcome EspNeopixel client at "; // + (client->remoteIP().toString());
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
#include <WiFi.h>
#include <ArduinoOSC.h>
#include "FastLED.h"

#define PIN         22
#define PIXEL_COUNT 24
#define FRAME_CACHE_SIZE 100

int frames[FRAME_CACHE_SIZE][PIXEL_COUNT][3];

int frameWriteIndex = 0;
int frameReadIndex = 0;

CRGB neopixel[PIXEL_COUNT];

const String ssid = "TotallyNotSkynet";
const String password = "CabinetPolicySkipFir3$";

const int WIFI_TIMEOUT = 5000;
bool connected = false;

struct QNode {
    String frame;
    QNode* next;
    QNode(String f)
    {
        frame = f;
        next = NULL;
    }
};

struct Queue {
    QNode *front, *rear;
    int size;
    Queue()
    {
        front = rear = NULL;
        size = 0;
    }

    void enQueue(String f)
    {
        size++;

        // Create a new LL node
        QNode* temp = new QNode(f);

        // If queue is empty, then
        // new node is front and rear both
        if (rear == NULL) {
            front = rear = temp;
            return;
        }

        // Add the new node at
        // the end of queue and change rear
        rear->next = temp;
        rear = temp;
    }

    // Function to remove
    // a key from given queue q
    String deQueue()
    {
      size--;
        // If queue is empty, return NULL.
        if (front == NULL)
            return "";

           String frame = front->frame;

        // Store previous front and
        // move front one node ahead
        QNode* temp = front;
        front = front->next;

        // If front becomes NULL, then
        // change rear also as NULL
        if (front == NULL)
            rear = NULL;

        delete (temp);

        return frame;
    }
};

Queue queue;


int frameStarted = millis();
bool started = false;

int pixelColours[PIXEL_COUNT][3];

bool updating = false;

int frameRate = 10;
int frameDuration = 1000 / frameRate;


void setup() {
  Serial.begin(115400);
  FastLED.addLeds<NEOPIXEL, 22>(neopixel, PIXEL_COUNT);

  startWiFi();
  attachOscListener();

  FastLED.show();
  frameStarted = millis();
}

void loop() {
  if ( connected ) OscWiFi.update();

  if ( queue.size > 10 ) {
    if ( millis() - frameStarted >= frameDuration ) {
      String frame = queue.deQueue();
      displayFrame(queue.deQueue());
      frameStarted = millis();
    }
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
  int p = 0;
  for ( int i = 0; i < (PIXEL_COUNT * 3); i += 3 ) {
    int red = getValue(frame, ' ', i).toInt();
    int green = getValue(frame, ' ', i+1).toInt();
    int blue = getValue(frame, ' ', i+2).toInt();
    neopixel[p] = CRGB(red, green, blue);
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


#include <Adafruit_TFTLCD.h>
#include <Adafruit_GFX.h>
#include <pin_magic.h>
#include <Servo.h> 

#define	BLACK   0x0000
#define	BLUE    0x001F
#define	RED     0xF800
#define	GREEN   0x07E0
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define WHITE   0xFFFF
 
int panPin = 2;
int tiltPin = 3;
int panZero = 90;
int tiltZero = 70;
Servo pan, tilt;// create servo object to control a servo 
                // a maximum of eight servo objects can be created 
 
int pos = 0;    // variable to store the servo position 


// The control pins for the LCD can be assigned to any digital or
// analog pins...but we'll use the analog pins as this allows us to
// double up the pins with the touch screen (see the TFT paint example).
#define LCD_CS A3 // Chip Select goes to Analog 3
#define LCD_CD A2 // Command/Data goes to Analog 2
#define LCD_WR A1 // LCD Write goes to Analog 1
#define LCD_RD A0 // LCD Read goes to Analog 0

#define LCD_RESET A4 // Can alternately just connect to Arduino's reset pin

// When using the BREAKOUT BOARD only, use these 8 data lines to the LCD:
// For the Arduino Uno, Duemilanove, Diecimila, etc.:
//   D0 connects to digital pin 8  (Notice these are
//   D1 connects to digital pin 9   NOT in order!)
//   D2 connects to digital pin 2
//   D3 connects to digital pin 3
//   D4 connects to digital pin 4
//   D5 connects to digital pin 5
//   D6 connects to digital pin 6
//   D7 connects to digital pin 7
// For the Arduino Mega, use digital pins 22 through 29
// (on the 2-row header at the end of the board).

// Assign human-readable names to some common 16-bit color values:
#define	BLACK   0x0000
#define	BLUE    0x001F
#define	RED     0xF800
#define	GREEN   0x07E0
#define CYAN    0x07FF
#define MAGENTA 0xF81F
#define YELLOW  0xFFE0
#define WHITE   0xFFFF

Adafruit_TFTLCD screen(LCD_CS, LCD_CD, LCD_WR, LCD_RD, LCD_RESET);
// If using the shield, all control and data lines are fixed, and
// a simpler declaration can optionally be used:
// Adafruit_TFTLCD tft;

int prevSayHello = 0;
 
void setup() 
{ 
  Serial.begin(9600);
  pan.attach(panPin);
  tilt.attach(tiltPin);
  screen.reset();
  uint16_t id = screen.readID();
  screen.begin(id);
  screen.fillScreen(BLACK);
  screen.setTextColor(WHITE);
  screen.setTextSize(3);
  screen.setRotation(3);
  screen.println("Booting Up");
  pan.write(panZero);
  tilt.write(tiltZero);
  
  establishContact();
} 
 
 
void loop() 
{ 
  if (Serial.available() > 0){
    //first get the pan amount
    char panIn = Serial.read();
    pan.write(panZero + panIn);
    //then get tilt
    char tiltIn = Serial.read();
    tilt.write(tiltZero + tiltIn);
    //then if there is anyone...
    byte sayHello = Serial.read();
    if (sayHello != prevSayHello){
      screen.fillScreen(BLACK);
      if (sayHello != 0){
        screen.setTextColor(WHITE);
        screen.setCursor(0, 0);
        screen.setTextSize(3);
        if (sayHello == 1){
          screen.println("Hello!");
        } else if (sayHello == 2){
          screen.println("How are you?");
        } else if (sayHello == 3){
          screen.println("I'm sorry to hear that");
        } else if (sayHello == 4){
          screen.println("Thats good to hear");
        } else if (sayHello == 5){
          screen.println("I'm good, thanks");
        } else if (sayHello == 6){
          screen.println("Bye");
        } else if (sayHello == 7){
          screen.println("I'm sorry, I don't understand");
        } else if (sayHello == 8){
          screen.println("Don't Touch This!");
          screen.println("{daaa-na-na-na)");
        }
      }
      prevSayHello = sayHello;
    }
    delay(100);
    Serial.write(1);
  }
} 

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}

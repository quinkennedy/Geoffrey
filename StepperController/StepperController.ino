// Adafruit Motor shield library
// copyright Adafruit Industries LLC, 2009
// this code is public domain, enjoy!

#include <AFMotor.h>

int stepsPerRot = 400;
int motorSpeed = 10;

// Connect a stepper motor with 48 steps per revolution (7.5 degree)
// to motor port #1 (M1 and M2)
AF_Stepper motor(stepsPerRot, 1);

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps

  motor.setSpeed(motorSpeed);  // 10 rpm
  establishContact();  // send a byte to establish contact until receiver responds 
}

void loop() {
  if (Serial.available() > 0){
    byte inByte = Serial.read();
    if (inByte > 100){
      motor.step(stepsPerRot/4, BACKWARD, DOUBLE);
    } else {//or DOUBLE?
      motor.step(stepsPerRot/4, FORWARD, DOUBLE);
    }
    Serial.write(inByte);
  }
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}

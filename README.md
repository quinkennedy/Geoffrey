*Geoffrey*
A robot that looks around for a person to interact with. It's conversation skills are quite limited at the moment, but it will try.

***Setup***
Uses the Creative Intel Perceptual Computing camera, which only has windows drivers as of this writing. FaceTracking runs in processing (and does more than just face tracking). ScreenServoController and StepperController run on Arduinos. Everything talks via serial.

***Required Libraries***
https://github.com/adafruit/Adafruit-Motor-Shield-library
https://github.com/adafruit/TFTLCD-Library
https://github.com/adafruit/adafruit-gfx-library
http://software.intel.com/en-us/vcsource/tools/perceptual-computing-sdk There is some complicated way to find the Processing library for the SDK, hopefully it is documented somewhere because I don't remember...


/// Written by Che-Wei Wang, Taylor Levy & Will Patrick
/// MIT Media Lab, 2014

// The controller uses the AccelStepper library.
// You can download the library at https://github.com/paul-ferragut/ofxStepperMotors/tree/master/arduino/AccelStepper

// example gcode
// G0X100 //moves 100 steps as travel speed (fast)
// S100 // set normal speed to 100 steps per second
// G1X200 //moves 200 steps at set speed

#include <AccelStepper.h>

int motorSpeed = 25; // Maximum steps per second (about 3rps / at 16 microsteps)
int motorAccel = 500; // Steps/second/secoand to accelerate
int travelSpeed = 1000; // max speed for fast travel // G0

// Input pins on the ATMega328 for the stepper motor
int Input1A = A0;
int Input2A = A1;
int Input1B = A4;
int Input2B = A3;

String command = "";

// Set up the AccelStepper intance
AccelStepper stepper(AccelStepper::HALF4WIRE, A0, A1, A4, A3);

int sofar;  // How much is in the buffer
#define MAX_BUF (64)  // What is the longest message Arduino can store? 64 characters
char buffer[MAX_BUF];  // Where we store the message until we get a ';'

void setup() {
  //set default speeds
  stepper.setMaxSpeed(motorSpeed);
  stepper.setSpeed(motorSpeed);
  stepper.setAcceleration(motorAccel);
  stepper.moveTo(-50); // move 50 steps 
  Serial.begin(9600);     // opens serial port, sets data rate to 9600 bps
}

void loop() {
  checkSerial();
  stepper.run();
}


void checkSerial() {

  // listen for commands
  while (Serial.available() > 0) { // if something is available
    char c = Serial.read(); // get it
    if (sofar < MAX_BUF) buffer[sofar++] = c; // store it
    if (buffer[sofar - 1] == ';') break; // entire message received
  }

  if (sofar > 0 && buffer[sofar - 1] == ';') {
    // we got a message and it ends with a semicolon
    buffer[sofar] = 0; // end the buffer so string functions work right
    Serial.print(F("\r\n"));  // echo a return character for humans
        ready();
        
    processCommand();  // do something with the command
  }
}


void processCommand() {

  int posTemp = 0;
  int sp=0;

  // look for commands that start with 'G'
  int cmd = parsenumber('G');
  switch (cmd) {
  case  0: // move fast
    sp= parsenumber('S'); //get speed
    stepper.setMaxSpeed(travelSpeed);
    stepper.setSpeed(travelSpeed);
    posTemp = parsenumber('X');
    stepper.moveTo(stepper.currentPosition() + posTemp);
    break;

  case  1: // move in a line
    sp = parsenumber('S'); //get speed
    stepper.setMaxSpeed(sp);
    stepper.setSpeed(sp);
    posTemp = parsenumber('X');
    stepper.moveTo(stepper.currentPosition() + posTemp);
    break;
    
  default:
    break;
    // if the string has no G or M commands it will get here and the Arduino will silently ignore it
  }
}

int parsenumber(char c) {

  String tempCharString = "";
  boolean isNegative = false;

  for (int i = 0; i < MAX_BUF; i++)
  {
    if (buffer[i] == c)
    {
      while (buffer[i] != ' ')//look for spaces
      {
        i++;
        tempCharString += buffer[i];
      }
      return tempCharString.toInt();
    }
  }
  return 0;
  
}

void ready() {
  sofar = 0; // clear input buffer
  Serial.print("a"); //send 'a' to processing to say we're ready for next line
}









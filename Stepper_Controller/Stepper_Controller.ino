


//download library at https://github.com/adafruit/AccelStepper
#include <AccelStepper.h>

int motorSpeed = 9600; //maximum steps per second (about 3rps / at 16 microsteps)
int motorAccel = 80000; //steps/second/secoand to accelerate

int motorDirPin = 2; //digital pin 2
int motorStepPin = 3; //digital pin 3

//set up the accelStepper intance
//the "1" tells it we are using a driver
AccelStepper stepper(1, motorStepPin, motorDirPin); 

int sofar;  // how much is in the buffer
#define MAX_BUF (64)  // What is the longest message Arduino can store?
char buffer[MAX_BUF];  // where we store the message until we get a ';'

void setup(){
  stepper.setMaxSpeed(motorSpeed);
  stepper.setSpeed(motorSpeed);
  stepper.setAcceleration(motorAccel);
  
  
  stepper.moveTo(900*5); //move 900 steps (should be 5 rev)


  Serial.begin(9600);     // opens serial port, sets data rate to 9600 bps


}

void loop(){

  // listen for commands
  while(Serial.available() > 0) {  // if something is available
    char c=Serial.read();  // get it
    Serial.print(c);  // repeat it back so I know you got the message
    if(sofar<MAX_BUF) buffer[sofar++]=c;  // store it
    if(buffer[sofar-1]==';') break;  // entire message received
  }

  if(sofar>0 && buffer[sofar-1]==';') {
    // we got a message and it ends with a semicolon
    buffer[sofar]=0;  // end the buffer so string functions work right
    Serial.print(F("\r\n"));  // echo a return character for humans
    processCommand();  // do something with the command
    ready();
  }


  //  //if stepper is at desired location
  //  if (stepper.distanceToGo() == 0){
  //    //go the other way the same amount of steps
  //    //so if current position is 400 steps out, go position -400
  //    stepper.moveTo(-stepper.currentPosition()); 
  //  }

  
  
  //these must be called as often as possible to ensure smooth operation
  //any delay will cause jerky motion
  stepper.run();
}


void processCommand() {
  // look for commands that start with 'G'
  int cmd=parsenumber('G');
  switch(cmd) {
  case  0: // move in a line
  case  1: // move in a line
    stepper.setSpeed(parsenumber('S'));
    stepper.moveTo(parsenumber('X'));
    break;
  default:  
    break;
  }


  // if the string has no G or M commands it will get here and the Arduino will silently ignore it
}



int parsenumber(char c){
  
  //unfinished
  int n=0;

//G00 S900 X200

//read buffer

//read the chars after c and before space

//convert string to int



  return n;

}





void ready() {
  sofar=0;  // clear input buffer
  Serial.print(F(">"));  // signal ready to receive input
}


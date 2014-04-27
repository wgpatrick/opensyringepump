/// Hello! This is the stepper controller code for the Open Syringe Pump project.
/// Written by Che-Wei Wang, Taylor Levy & Will Patrick
/// MIT Media Lab, 2014

// The controller uses the AccelStepper library. 
// You can download the library at https://github.com/adafruit/AccelStepper

#include <AccelStepper.h>

int motorSpeed = 25; // Maximum steps per second (about 3rps / at 16 microsteps)
int motorAccel = 500; // Steps/second/secoand to accelerate

// Input pins on the ATMega328 for the stepper motor
int Input1A = A0;
int Input2A = A1;
int Input1B = A4;
int Input2B = A3;

// Set up the AccelStepper intance
// The "4" tells the library that we are using a 4 wire stepper motor

AccelStepper stepper(AccelStepper::HALF4WIRE,A0,A1,A4,A3);

int sofar;  // How much is in the buffer
#define MAX_BUF (12)  // What is the longest message Arduino can store? 64 characters
char buffer[MAX_BUF];  // Where we store the message until we get a ';'

void setup(){

  stepper.setMaxSpeed(motorSpeed);
  stepper.setSpeed(motorSpeed);
  stepper.setAcceleration(motorAccel);

  stepper.moveTo(-50); // move 1000 steps (should be 5 rev)
  Serial.begin(9600);     // opens serial port, sets data rate to 9600 bps

}
 
void loop(){
  checkSerial();

  //if stepper is at desired location
  if (stepper.distanceToGo() == 0){
    //go the other way the same amount of steps
    //so if current position is 400 steps out, go position -400
    // stepper.moveTo(-stepper.currentPosition()); 
  }
  //these must be called as often as possible to ensure smooth operation
  //any delay will cause jerky motion
  stepper.run();
}
String command="";

void checkSerial() {
  // listen for commands
  while(Serial.available() > 0) {  // if something is available
    char c=Serial.read();  // get it
    //Serial.print(c);  // repeat it back so I know you got the message
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
}


// prcessCommand()

int posTemp = 0;
void processCommand() {

  Serial.print("a"); 
  // look for commands that start with 'G'
  int cmd=parsenumber('G');
  switch(cmd) {
    case  0: // move in a line
    //Serial.print("0");
    break;
  case  1: // move in a line
    posTemp = parsenumber('X');
    stepper.moveTo(stepper.currentPosition() + posTemp);
    break;
    
  default:  
    break;
    // if the string has no G or M commands it will get here and the Arduino will silently ignore it
  }

}



int parsenumber(char c){

  //unfinished
  String tempCharString = "";
  boolean isNegative = false;
  
  for(int i = 0; i<MAX_BUF; i++)
  {
    if(buffer[i] == c)
    {
      while(buffer[i] != ' ')
      {
        i++;
//        if(buffer[i] == '-')
//          isNegative = true;
//        else
          tempCharString += buffer[i];
      }
//      if(isNegative)
//        return tempCharString.toInt()*-1;
//      else
        return tempCharString.toInt();
        
    }
  }
  return 0;
  //G00 S900 X200

    //read buffer

  //read the chars after c and before space

  //convert string to int

}





void ready() {
  sofar=0;  // clear input buffer
  // memset(buffer, 0, MAX_BUF); // clear the buffer
  //Serial.print(F(">"));  // signal ready to receive input
  //Serial.print("done");  // signal ready to receive input

}




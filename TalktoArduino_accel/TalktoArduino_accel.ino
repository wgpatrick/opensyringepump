#include <SoftwareSerial.h>
#include <AccelStepper.h>

SoftwareSerial mySerial(0,1);
// Pins

// Pins for serial communications
int TX = 1;
int RX = 0;

// Inputs to motor driver from ATTiny
int Input1A = A0;
int Input2A = A1;
int Input1B = A4;
int Input2B = A3;
int Steps = 400;
AccelStepper mystepper(4,A0,A1,A4,A3);//(4,Input1A,Input2A,Input1B,Input2B);

void setup()
{
mySerial.begin(57600);
mySerial.println("Hello, world?");
mystepper.setMaxSpeed(1000);
mystepper.setAcceleration(50);
mystepper.moveTo(2000);
}
 
void loop()
{

  // If at the end of travel go to the other end
    if (mystepper.distanceToGo() == 0)
      mystepper.moveTo(-mystepper.currentPosition());
    mystepper.run();

   
    mySerial.println("Done...");

}

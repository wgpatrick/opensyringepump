#include <SoftwareSerial.h>
#include <Stepper.h>

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
Stepper myStepper = Stepper(Steps,Input1A,Input2A,Input1B,Input2B);

void setup()
{
mySerial.begin(57600);
mySerial.println("Hello, world?");
myStepper.setSpeed(10);
}
 
void loop()
{

mySerial.println("Down!");
myStepper.step(Steps);
mySerial.println("Done...");
delay(1000);

mySerial.println("Up!");
myStepper.step(-Steps);
mySerial.println("Done...");
delay(1000);

}

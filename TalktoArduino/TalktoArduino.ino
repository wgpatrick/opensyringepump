#include <SoftwareSerial.h>
#include <Stepper.h>

SoftwareSerial mySerial(6,7);
// Pins

// Pins for serial communications
int TX = 6;
int RX = 7;

// Inputs to motor driver from ATTiny
int Input1A = 4;
int Input2A = 5;
int Input1B = 0;
int Input2B = 1;
int Steps = 200;
Stepper myStepper = Stepper(Steps,Input1A,Input2A,Input1B,Input2B);

void setup()
{
mySerial.begin(9600);
mySerial.println("Hello, world?");
myStepper.setSpeed(10);
}
 
void loop()
{

myStepper.step(Steps);
delay(100);


myStepper.step(-Steps);
delay(100);

}

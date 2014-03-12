#include <IEEE754tools.h>
SoftwareSerial mySerial(0,1);

// Pins

// Pins for serial communications
int TX = 6;
int RX = 7;


// Inputs to motor driver from ATTiny
int Input1A = ;
int Input2A = ;
int Input1B = ;
int Input2B = ;

void setup()
{
  pinMode(RX,INPUT);
  pinMode(TX,OUTPUT);
  Serial.begin(9600);
}

void loop()
{
  
}

import controlP5.*;
ControlP5 cp5;
String uLValue = "";
boolean direction = false;

import processing.serial.*;

float flowRate;
float totalFlow;
float ulPerRevolution;
float syringeInnerDiameter;
float pitch;
int stepsPerRevolution;

String gCodeString;

Serial myPort; 

void setup()
{
  size(1000,300);
  
  // List all the available serial ports:
  println(Serial.list());

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[5], 9600);
  
  // Send a capital A out the serial port:
  //myPort.write(65);
    PFont font = createFont("AndaleMono-48.vlw",12, true);
    textFont(font);
    ControlFont cfont = new ControlFont(font,241);
    
    cp5 = new ControlP5(this);
    // change the original colors
    cp5.setColorForeground(0xffaaaaaa);
    cp5.setColorBackground(0xffffffff);
    cp5.setColorLabel(0xff555555);
    cp5.setColorValue(0xff00ff00);
    cp5.setColorActive(0xff000000);
  
  cp5.addTextfield("total ul")
     .setPosition(10,10)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("30")
     .setLabel("total fluid to move (uL)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("flowRateField")
     .setPosition(10,60)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText(".5")
     .setLabel("flow rate (ul/sec)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("syringeInnerDiameterField")
   .setPosition(150,10)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("3")
   .setLabel("Syringe inner diameter (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("pitchField")
   .setPosition(150,60)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("8")
   .setLabel("Pitch of threaded rod (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("stepsPerRevolutionField")
   .setPosition(150,110)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("16")
   .setLabel("Number steps per revolution")
   .setAutoClear(false).keepFocus(false);
   ;

  color c = color(0,0,255);
  smooth();
  
  flowRate=0;
  totalFlow=0;
  ulPerRevolution=0;
  stepsPerRevolution=0;
  gCodeString = "%\n%";

}

void draw()
{
  background(245);
  debugStates();
}

// G50 S2000 -> set spindle speed... is this movment speed?
void debugStates()
{
  
  pushMatrix();
  translate(10,190);
  fill(50);
  //text ("arrow up/down to zero syringe pump", 0, 0);
 
  totalFlow = float(cp5.get(Textfield.class,"total ul").getText().trim());
  flowRate = float(cp5.get(Textfield.class,"flowRateField").getText().trim());
  syringeInnerDiameter = float(cp5.get(Textfield.class,"syringeInnerDiameterField").getText().trim());
  pitch = float(cp5.get(Textfield.class,"pitchField").getText().trim());
  stepsPerRevolution = int(cp5.get(Textfield.class,"stepsPerRevolutionField").getText().trim());
  
  ulPerRevolution = syringeInnerDiameter * PI * pitch;
  
  String dir = "PUSH";
  if(!direction)
    dir = "PULL";
  
  text("Motor + syringe settings : "+ ulPerRevolution +"uL/revolution *** 1 step = " + stepsPerRevolution/ulPerRevolution + "uL *** 1 uL = "+1/(stepsPerRevolution/ulPerRevolution) +"steps", 0, 0);
  text("Program settings : "+totalFlow +"uL @ " + flowRate +"uL/s, direction : " + dir, 0, 20);
  
  gCodeString = "G01"+" S"+str(20)+" X"+str(03)+";";
  text("GCODE PREVIEW :\n" + gCodeString, 0, 40);
  
  popMatrix();
}
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
}

void keyPressed() {
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      // send Gcode position up 1
      println("manualMode : send gcode position up 1");
      myPort.write("G01 S9600 X450;");
    } 
    else if (keyCode == DOWN) 
    {
      // send Gcode position down 1
      println("manualMode : send gcode position down 1");
      myPort.write("G01 S9600 X-450;");
    } 
    else if (keyCode == LEFT) 
    {
      
    } 
    else if (keyCode == RIGHT) 
    {
      
    }  
  }
  else
  {
    if(key == 'd')
    {
      direction = !direction;
    }
    else if (key == 'p')
    {
    //myPort.write(65);
    }
  }
    
}



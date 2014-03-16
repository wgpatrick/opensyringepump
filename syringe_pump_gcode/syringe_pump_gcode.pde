import controlP5.*;
ControlP5 cp5;
String uLValue = "";
String direction = "PUSH";

import processing.serial.*;

float flowRate;
float totalFlow;
float ulPerStep;
float syringeInnerDiameter;
float mmPerStep;

String gCodeString;

Serial myPort; 

void setup()
{
  size(500,500);
  
  // List all the available serial ports:
  println(Serial.list());

  // Open the port you are using at the rate you want:
  //myPort = new Serial(this, Serial.list()[0], 9600);
  
  // Send a capital A out the serial port:
  //myPort.write(65);
    PFont font = createFont("AndaleMono-48.vlw",12, true);
    textFont(font);
    ControlFont cfont = new ControlFont(font,241);
    
    cp5 = new ControlP5(this);
    // change the original colors
    cp5.setColorForeground(0xffaaaaaa);
    cp5.setColorBackground(0xffffffff);
    cp5.setColorLabel(0xff777777);
    cp5.setColorValue(0xff00ff00);
    cp5.setColorActive(0xff000000);
  
  cp5.addTextfield("total ul")
     .setPosition(10,10)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("")
     .setLabel("total fluid to move (uL)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("flowRateField")
     .setPosition(10,60)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("")
     .setLabel("flow rate (ul/sec)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("syringeInnerDiameterField")
   .setPosition(150,10)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("")
   .setLabel("Syringe inner diameter (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("mmPerStepField")
   .setPosition(150,60)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("")
   .setLabel("Linear movement per Motor Step (mm)")
   .setAutoClear(false).keepFocus(false);
   ;

  color c = color(0,0,255);
  smooth();
  
  flowRate=0;
  totalFlow=0;
  ulPerStep=0;
  
  gCodeString = "%\n%";

}

void draw()
{
  background(230);
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
  mmPerStep = float(cp5.get(Textfield.class,"mmPerStepField").getText().trim());

  ulPerStep = syringeInnerDiameter * PI * mmPerStep;
  
  text("Motor + syringe settings : "+ ulPerStep +"uL/step", 0, 0);
  text("Program settings : "+totalFlow +"uL @ " + flowRate +"uL/s", 0, 20);
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
      //myPort.write(65);
    } 
    else if (keyCode == DOWN) 
    {
      // send Gcode position down 1
      println("manualMode : send gcode position down 1");
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
    if(key == 'm')
    {
      
    }
    else if (key == 'p')
    {

    }
  }
    
}



import controlP5.*;
ControlP5 cp5;
String uLValue = "";

import processing.serial.*;

float flowRate;
float totalFlow;
float ulPerRevolution;
float volume_per_step;
float numsteps_per_microliter;
float syringeInnerDiameter;
float pitch;
int stepsPerRevolution;
float num_steps_vol;
float speed_steps_per_second;
DropdownList box;
String dir;

String gCodeString;

Serial myPort; 

void setup()
{
  size(1000,400);
  
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
   
   // LEFT COLUMN. INPUTS.
   
   cp5.addTextfield("syringeInnerDiameterField")
   .setPosition(10,10)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("4")
   .setLabel("Syringe inner diameter (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("pitchField")
   .setPosition(10,60)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("8")
   .setLabel("Pitch of threaded rod (mm)")
   .setAutoClear(false).keepFocus(false);
   ;
   
   cp5.addTextfield("stepsPerRevolutionField")
   .setPosition(10,110)
   .setSize(100,25)
   .setFont(font)
   .setFocus(false)
   .setColor(color(50,50,50))
   .setText("200")
   .setLabel("Number steps per revolution")
   .setAutoClear(false).keepFocus(false);
   ;
   
   // CENTRAL COLUMN. PROGRAMMING THE FLOW
  
  cp5.addTextfield("total ul")
     .setPosition(150,10)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("30")
     .setLabel("total fluid to move (uL)")
     .setAutoClear(false).keepFocus(false);
     ;
     
  cp5.addTextfield("flowRateField")
     .setPosition(150,60)
     .setSize(100,25)
     .setFont(font)
     .setFocus(false)
     .setColor(color(50,50,50))
     .setText("5")
     .setLabel("flow rate (ul/sec)")
     .setAutoClear(false).keepFocus(false);
     ;
     
     
   box = cp5.addDropdownList("direction")
     .setPosition(150, 130)
     .setBackgroundColor(color(190))
     .setItemHeight(20)
     .setBarHeight(15)
     ;
      
     box.captionLabel().set("Direction");
     box.captionLabel().style().marginTop = 3;
     box.captionLabel().style().marginLeft = 3;
     box.valueLabel().style().marginTop = 3;
     box.addItem("Pull",0);
     box.addItem("Push",1);
     box.setColorActive(color(255, 128));
    
  color c = color(0,0,255);
  smooth();
  
  flowRate=0;
  totalFlow=0;
  ulPerRevolution=0;
  volume_per_step =0;
  numsteps_per_microliter=0;
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
  
  
  //// GRABBING VALUES FROM FIELDS
  totalFlow = float(cp5.get(Textfield.class,"total ul").getText().trim());
  flowRate = float(cp5.get(Textfield.class,"flowRateField").getText().trim());
  syringeInnerDiameter = float(cp5.get(Textfield.class,"syringeInnerDiameterField").getText().trim());
  pitch = float(cp5.get(Textfield.class,"pitchField").getText().trim());
  stepsPerRevolution = int(cp5.get(Textfield.class,"stepsPerRevolutionField").getText().trim());
  
  /// CALCULATING OUTPUT NUMBER OF STEPS AND STEP SPEED
  ulPerRevolution = sq(syringeInnerDiameter) / 4 * PI * pitch;
  volume_per_step = ulPerRevolution / (stepsPerRevolution*2); // *2, because we are half stepping
  numsteps_per_microliter = 1 / volume_per_step;
 
  num_steps_vol = totalFlow * numsteps_per_microliter;
  speed_steps_per_second = flowRate / volume_per_step;
  
  
  
  text("uL per revolution: " + str(ulPerRevolution),0,0);
  text("volume per step: "+ str(volume_per_step),0,20);
  text("number of steps per microliter: "+ str(numsteps_per_microliter),0,40);
  text("Program settings : "+ totalFlow + "uL @ " + flowRate +"uL/s, direction : " + dir, 0, 60);
  text("Number of steps to move fluid: " + str(num_steps_vol),0,80);
  text("Step speed: " + str(speed_steps_per_second) + " steps / second",0,100);
  text("Direction: " + dir,0,120);
  gCodeString = "G01"+" S"+str(20)+" X"+str(03)+";";
  text("GCODE PREVIEW :\n" + gCodeString, 0, 140);
  
  popMatrix();
}
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
   if (theEvent.getGroup().getValue()==0.0) {
     dir = "PULL"; 
    }
    else if (theEvent.getGroup().getValue()==1.0) {
      dir ="PUSH";
    }
    
  }
 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
  
  
}

void keyPressed() {
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      // send Gcode position up 1
      println("manualMode : send gcode position up 1");
      myPort.write("G01 X+"+int(num_steps_vol)+";");
    } 
    else if (keyCode == DOWN) 
    {
      // send Gcode position down 1
      println("manualMode : send gcode position down 1");
      myPort.write("G01 X-"+int(num_steps_vol)+";");
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
   
    if (key == 's')
    {
    //println("set speed");
    //myPort.write("G00 S"+percentMotorSpeed+";");
    }
  }
    
}

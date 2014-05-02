import controlP5.*;
ControlP5 cp5;
String uLValue = "";
int direction = 1;
boolean commandReady = true;

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
PFont font = createFont("AndaleMono-48.vlw", 12, true);

DropdownList box;
String gCodeString;
Serial myPort; 
Table table;


int xOffset=70;
int yOffset=30;

void setup()
{
  size(400, 600);
  // List all the available serial ports:
  println(Serial.list());

  loadSettings();

  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[7], 9600);

  // Send a capital A out the serial port:
  myPort.write(65);

  textFont(font);
  ControlFont cfont = new ControlFont(font, 241);

  cp5 = new ControlP5(this);
  // change the original colors
  cp5.setColorForeground(0xffaaaaaa);
  cp5.setColorBackground(0xffffffff);
  cp5.setColorLabel(0xff555555);
  cp5.setColorValue(0xff00ff00);
  cp5.setColorActive(0xff000000);


  // LEFT COLUMN. INPUTS.
  cp5.addTextfield("syringeInnerDiameterField")
    .setPosition(10+xOffset, 10+yOffset)
      .setSize(100, 25)
        .setFont(font)
          .setFocus(false)
            .setColor(color(50, 50, 50))
              .setText(""+syringeInnerDiameter)
                .setLabel("Syringe inner diameter (mm)")
                  .setAutoClear(false).keepFocus(false);
  ;

  cp5.addTextfield("pitchField")
    .setPosition(10+xOffset, 60+yOffset)
      .setSize(100, 25)
        .setFont(font)
          .setFocus(false)
            .setColor(color(50, 50, 50))
              .setText(""+pitch)
                .setLabel("Pitch of threaded rod (mm)")
                  .setAutoClear(false).keepFocus(false);
  ;

  cp5.addTextfield("stepsPerRevolutionField")
    .setPosition(10+xOffset, 110+yOffset)
      .setSize(100, 25)
        .setFont(font)
          .setFocus(false)
            .setColor(color(50, 50, 50))
              .setText(""+stepsPerRevolution)
                .setLabel("Number steps per revolution")
                  .setAutoClear(false).keepFocus(false);
  ;


  // CENTRAL COLUMN. PROGRAMMING THE FLOW

  cp5.addTextfield("total ul")
    .setPosition(150+xOffset, 10+yOffset)
      .setSize(100, 25)
        .setFont(font)
          .setFocus(false)
            .setColor(color(50, 50, 50))
              .setText(""+totalFlow)
                .setLabel("total fluid to move (uL)")
                  .setAutoClear(false).keepFocus(false);
  ;

  cp5.addTextfield("flowRateField")
    .setPosition(150+xOffset, 60+yOffset)
      .setSize(100, 25)
        .setFont(font)
          .setFocus(false)
            .setColor(color(50, 50, 50))
              .setText(""+flowRate)
                .setLabel("flow rate (ul/sec)")
                  .setAutoClear(false).keepFocus(false);
  ;


  cp5.addButton("PULL")
    .setValue(0)
      .setPosition(10+xOffset, 170+yOffset)
        .setSize(100, 45)
          ;
  cp5.addButton("PUSH")
    .setValue(0)
      .setPosition(150+xOffset, 170+yOffset)
        .setSize(100, 45)
          ;


  color c = color(0, 0, 255);
  smooth();

  //  flowRate=0;
  //  totalFlow=0;
  //  ulPerRevolution=0;
  //  volume_per_step =0;
  //  numsteps_per_microliter=0;
  //  stepsPerRevolution=0;
  gCodeString = "%\n%";
}


void draw()
{
  background(245);
  readSerial();
  debugStates();
}

// G50 S2000 -> set spindle speed... is this movment speed?
void debugStates()
{

  //// GRABBING VALUES FROM FIELDS
  totalFlow = float(cp5.get(Textfield.class, "total ul").getText().trim());
  flowRate = float(cp5.get(Textfield.class, "flowRateField").getText().trim());
  syringeInnerDiameter = float(cp5.get(Textfield.class, "syringeInnerDiameterField").getText().trim());
  pitch = float(cp5.get(Textfield.class, "pitchField").getText().trim());
  stepsPerRevolution = int(cp5.get(Textfield.class, "stepsPerRevolutionField").getText().trim());

  /// CALCULATING OUTPUT NUMBER OF STEPS AND STEP SPEED
  ulPerRevolution = sq(syringeInnerDiameter) / 4 * PI * pitch;
  volume_per_step = ulPerRevolution / (stepsPerRevolution*2); // *2, because we are half stepping
  numsteps_per_microliter = 1 / volume_per_step;

  num_steps_vol = totalFlow * numsteps_per_microliter;
  speed_steps_per_second = flowRate / volume_per_step;

  textFont(loadFont("Courier-12.vlw"));

  pushMatrix();
  translate(10+xOffset, 250+yOffset);
  fill(50);
  text("uL per revolution: " + str(ulPerRevolution), 0, 0);
  text("volume per step: "+ str(volume_per_step), 0, 20);
  text("number of steps per microliter: "+ str(numsteps_per_microliter), 0, 40);
  //text("Program settings : "+ totalFlow + "uL @ " + flowRate +"uL/s", 0, 60);
  text("Number of steps to move fluid: " + str(num_steps_vol), 0, 80);
  text("Step speed: " + str(speed_steps_per_second) + " steps / second", 0, 100);

  gCodeString = "G01 S"+round(speed_steps_per_second)+" X+"+round(num_steps_vol)+";";
  text("UP    ARROW TO PUSH : " + gCodeString, 0, 140);
  gCodeString = "G01 S"+round(speed_steps_per_second)+" X-"+round(num_steps_vol)+";";
  text("DOWN  ARROW TO PULL : " + gCodeString, 0, 160);
  
  
  text("FOR FAST TRAVEL:", 0, 200);
  gCodeString = "G00 S"+round(speed_steps_per_second)+" X+"+round(num_steps_vol)+";";
  text("LEFT  ARROW : " + gCodeString, 0, 220);
  gCodeString = "G00 S"+round(speed_steps_per_second)+" X-"+round(num_steps_vol)+";";
  text("RIGHT ARROW : " + gCodeString, 0, 240);

  text("COMMAND READY : " + commandReady, 0, 280);  

  popMatrix();
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );
  }
  if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}

void readSerial()
{
  int inByte = 0;
  while (myPort.available () > 0) {
    inByte = myPort.read();
    println(inByte);
  }
  // 'a' is 97 as an int
  if (inByte == 97)
  {
    commandReady = true;
  }
}

void keyPressed() {
  saveSettings();

  //println("Key: " + str(key) + " " + int(key) + ", KeyCode: " + keyCode); 
  if (commandReady)
  {
    if (key == CODED) 
    {
      if (keyCode == UP) 
      {
        // send Gcode position up 1
        println("manualMode : send gcode position up 1");
        myPort.write("G01 S"+round(speed_steps_per_second)+" X+"+round(num_steps_vol)+";");
        commandReady = false;
      } 
      else if (keyCode == DOWN) 
      {
        // send Gcode position down 1
        println("manualMode : send gcode position down 1");
        myPort.write("G01 S"+round(speed_steps_per_second)+" X-"+round(num_steps_vol)+";");
        commandReady = false;
      }

      else if (keyCode == LEFT) 
      {
        // send Gcode position up 1
        println("manualMode : send gcode position up 1");
        myPort.write("G00 S"+round(speed_steps_per_second)+" X+"+round(num_steps_vol)+";");
        commandReady = false;
      } 
      else if (keyCode == RIGHT) 
      {
        // send Gcode position down 1
        println("manualMode : send gcode position down 1");
        myPort.write("G00 S"+round(speed_steps_per_second)+" X-"+round(num_steps_vol)+";");
        commandReady = false;
      }
    }
  }
}



//-----BUTTONS-----
public void PULL(int theValue) {
  println("a button event from PULL: "+theValue);
  myPort.write("G01 S"+round(speed_steps_per_second)+" X"+round(-1*num_steps_vol)+";");
  commandReady = false;
}

public void PUSH(int theValue) {
  println("a button event from PUSH: "+theValue);
  myPort.write("G01 S"+round(speed_steps_per_second)+" X"+round(num_steps_vol)+";");
  commandReady = false;
}
//-----BUTTONS-----






void saveSettings() {
  table = new Table();
  table.addColumn("flowRate");
  table.addColumn("totalFlow");
  table.addColumn("ulPerRevolution");
  table.addColumn("volume_per_step");
  table.addColumn("numsteps_per_microliter");
  table.addColumn("syringeInnerDiameter");
  table.addColumn("pitch");
  table.addColumn("stepsPerRevolution");
  table.addColumn("num_steps_vol");
  table.addColumn("speed_steps_per_second");

  TableRow newRow = table.addRow();
  newRow.setFloat("flowRate", flowRate);
  newRow.setFloat("totalFlow", totalFlow);
  newRow.setFloat("ulPerRevolution", ulPerRevolution);
  newRow.setFloat("volume_per_step", volume_per_step);
  newRow.setFloat("numsteps_per_microliter", numsteps_per_microliter);
  newRow.setFloat("syringeInnerDiameter", syringeInnerDiameter);
  newRow.setFloat("pitch", pitch);
  newRow.setInt("stepsPerRevolution", stepsPerRevolution);
  newRow.setFloat("num_steps_vol", num_steps_vol);
  newRow.setFloat("speed_steps_per_second", speed_steps_per_second);

  saveTable(table, "data.csv");
}

void loadSettings() {
  //load settings
  table = loadTable("data.csv", "header");
  println(table.getRowCount() + " total rows in table"); 
  for (TableRow row : table.rows()) {
    flowRate = row.getFloat("flowRate");
    totalFlow = row.getFloat("totalFlow");
    ulPerRevolution = row.getFloat("ulPerRevolution");
    volume_per_step= row.getFloat("volume_per_step");
    numsteps_per_microliter = row.getFloat("numsteps_per_microliter");
    syringeInnerDiameter = row.getFloat("syringeInnerDiameter");
    pitch = row.getFloat("pitch");
    stepsPerRevolution = row.getInt("stepsPerRevolution");
    num_steps_vol = row.getFloat("num_steps_vol");
    speed_steps_per_second = row.getFloat("speed_steps_per_second");
  }
}


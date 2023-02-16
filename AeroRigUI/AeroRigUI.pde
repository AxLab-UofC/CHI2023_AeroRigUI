/*
 * APP TEMPLATE Software for AerorigUI
 * University of Chicago, Axlab
 * https://www.axlab.cs.uchicago.edu/
 * Updated Feb 16, 2023
 * Contributer: Lilith Yu, Jesse Gao, and David Wu
 * Contact: knakagaki@uchicago.edu
*/


//For new Mac silicon chip to render 3D correctly:
import com.jogamp.opengl.GLProfile;
{
  GLProfile.initSingleton();
}

import java.util.*;

//communicate with server to control toios
import processing.net.*;
Client myClient;

// GUI control pannel
import peasy.PeasyCam;
PeasyCam cam;
import controlP5.*;
ControlP5 cp5;
Slider2D objectXYControl;
Slider zControl, pitchControl, yawControl, rollControl, stringAngleControl;
Toggle mouseToggle, joystickToggle, simToggle, handToggle;
Numberbox maxSpeed;
Accordion accordion;

// Safety GUI pannel
ControlP5 cpSafety;
Slider accelControl;
Textlabel safetyText, cautionText, maxAccel, maxAngle;
Textfield objectWeightTextField, numberOfRigBOtsTextField;
RadioButton controlRadio;
Bang divider;
Accordion accordionLeft;
float objWeight = 0.0f;
int numOfRigBotsSelected = 0;

//Object of Toios, Rigbots, Rigged objects and Connection Points
Cube[] cubes;
RigBot[] bots;
Object[] objects;
ConnectionPoint[] cps;

//first object's/connection point's position(x,y,z)
Point initPoint;
//keep recording the last recorded position(x,y)
PVector[] lastPoint;

int selectedObject = 0;
int angleController = 0; // Which angle to change (0 yaw, 1 pitch, 2 roll)
int controlCubeSwitching = 0;



/* -------------------------------------------------------------------------- */
/*                           initialization + setup                           */
/* -------------------------------------------------------------------------- */

//screen size setting
void settings() {
  if (!enable3Dview) size(1400, 1000);
  else size(1400, 1000, P3D);
}

void setup() {

  //Create a new port to connect to RasPi!
  myClient = new Client(this, "localhost", 8000);

  // * Init rigbots by cubes
  cubes = new Cube[nCubes];
  bots = new RigBot[nBots];
  for (int i = 0; i< cubes.length; ++i) {
    if (i % 2 == 1) {
      StringCube sc = new StringCube(i, false);
      cubes[i] = sc;
      // bot0 --> [cube0, cube1]; bot1 --> [cube2, cube3]; ...
      if (i / 2 < bots.length) {
        bots[i/2] = new RigBot(i/2, cubes[i - 1], sc);
      }
    } else {
      cubes[i] = new Cube(i, false);
    }
  }

  // * Init connection points and object
  cps = new ConnectionPoint[nBots];
  objects = new Object[nObjects];

  //set the first position
  initPoint = new Point(600, 140, botHeight);

  //single bot example:
  //cps[0] = new ConnectionPoint(0, initPoint, bots[0]);
  //objects[0] = new Object(0, new ConnectionPoint[]{cps[0]});

  //three bots example: NEED TO CONFIRM DISTANCE AND CHANGE BOT/CUBE NUMBER FIRST
  cps[0] = new ConnectionPoint(0, initPoint, bots[0]);
  cps[1] = new ConnectionPoint(1, cps[0], dist[0], bots[1]);
  cps[2] = new ConnectionPoint(2, cps[0], cps[1], dist[0], dist[1], bots[2]);
  objects[0] = new Object(0, new ConnectionPoint[]{cps[0], cps[1], cps[2]});

  //For antisway contol use
  lastPoint = new PVector[nBots];
  for(int i =0; i< nBots; i++){
      lastPoint[i] = new PVector(cps[i].getCenter().x, cps[i].getCenter().y);
  }


  setupGUI();
  setupPayloadTool();

  frameRate(appFrameRate);
  //textSize(10);
}

/* -------------------------------------------------------------------------- */
/*                                draw function                               */
/* -------------------------------------------------------------------------- */

void draw() {

  safetyCheck();

  if (!simControl){
    serverReceive();
  }

  displayDebug();
  displaySimulation();
  //calibrate();

///  ** APPLICATION AREA **////

  if(mouseControl){

      for(int i = 0; i < nObjects; i++ ){
          objects[selectedObject].translateObject(objectXYControl.getArrayValue()[0],
                                           objectXYControl.getArrayValue()[1],
                                           zControl.getValue(),
                                           yawControl.getValue() - objects[selectedObject].yaw,
                                           pitchControl.getValue() - objects[selectedObject].pitch,
                                           rollControl.getValue() - objects[selectedObject].roll,
                                           stringAngleControl.getValue(),
                                           cubes);
      }

  }


  if (!simControl) {
    checkLostCube();
    serverSend();
  }
}


void displaySimulation(){
  if(simControl && !mouseControl){
    //for simulation initial stage
    for(RigBot bot: bots){
      if(bot.linkedPoint != null){
        bot.simulateBots((int)bot.getLinkedPoint().getCenter().x, (int)bot.getLinkedPoint().getCenter().y);
      }
    }
  }
}

void checkLostCube() {
  //did we lost some cubes?
  long now = System.currentTimeMillis();
  for (int i = 0; i< nCubes; ++i) {
    // 500ms since last update
    if (cubes[i].lastUpdate < now - 1000 && cubes[i].isLost==false) {
      cubes[i].isLost= true;
      println("cube " + i + " is lost");
    }
  }
}





/* -------------------------------------------------------------------------- */
/*                         Toggle and button methods                         */
/* -------------------------------------------------------------------------- */

// toggle driving
void toggleDrive(boolean theFlag)
{
  if(theFlag==true) {
    mouseControl = false;
  } else {
    mouseControl = true;
  }
  //println("drive: "+mouseControl);
}

// toggle simulation
void toggleSim(boolean theFlag)
{
  if(theFlag==true) {
    simControl = false;
  } else {
    simControl = true;
  }
  //println("sim: "+simControl);
}

// // toggle joystick
// void toggleJoystick(boolean theFlag)
// {
//   if(theFlag==true) {
//     joystickControl = false;
//   } else {
//     joystickControl = true;
//   }
//   println(joystickControl);
// }

// change selected objects
void toggleObject(int theValue) {
  //println(“button event: “);
  selectedObject += theValue;
  selectedObject %= nObjects;

  // Change XYZ and angles values of GUI to match object
  objectXYControl.setValue(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y);
  zControl.setRange(70,  objects[selectedObject].maxZ).setValue(objects[selectedObject].objectCenter.z);
  yawControl.setValue(objects[selectedObject].yaw);
  pitchControl.setValue(objects[selectedObject].pitch);
  rollControl.setValue(objects[selectedObject].roll);
}

// toggle calibrate
void buttonCalibrate(boolean theFlag)
{
  if(!simControl){
    if (theFlag==false) {
      calibrateControl = true;
      mouseControl = false;
      simControl = false;
      objects[selectedObject].poseAllCubes();
      println("calibrating object " + objects[selectedObject].id);
    } else {
      return;
    }

    if (calibrateControl) {
        for(Object object: objects){
            object.calibrate();
        }
    }

  }
}

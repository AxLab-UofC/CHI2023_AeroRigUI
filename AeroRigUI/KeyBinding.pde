/* -------------------------------------------------------------------------- */
/*                                key bindings                                */
/* -------------------------------------------------------------------------- */

public void keyPressed() {
  switch(key) {

  //trans can keys
  // case 'g': // trash can open
  //   openCloseTrashCan(openCommand);
  //   break;

  // case 'r': // trash can close
  //   openCloseTrashCan(closeCommand);
  //   break;

  case '0': // reset
    break;

  case '4': // rotate test
    //cubes[1].rotatedDeg = 0;
     //motorControl(1, 1.3, -1.3, 100); //diff = 3 won't move
     //motorControl(1, 7, -7, 100); //diff = 16 won't move
     motorControl(1, 100, -100, 100); //diff = 19 at least this value
    break;
    case '5': // rotate test
    //cubes[1].rotatedDeg = 0;
     //motorControl(1, 1.3, -1.3, 100); //diff = 3 won't move
     //motorControl(1, 7, -7, 100); //diff = 16 won't move
     motorControl(1, -100, 100, 100); //diff = 19 at least this value
    break;

  case 'a':
    angleController++;
    angleController %= 3;
    break;

  //SET LEDs to the DEFAULT COLOR (light blue)
  case 'l':
    for (int i = 0; i < nCubes; i++) {
      ledControl(i, 0, 10, 10, 0);
    }
    break;

  // Changing z value ( based on the object )
  case '+':
    if (!mouseControl)
      break;
    objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z + 5, 0, 0, 0, 0, cubes);
    break;

  case '-':
    if (!mouseControl)
      break;
    objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z - 5, 0, 0, 0, 0, cubes);
    break;

  // Change angle value (based on object)
  case 'x':
    //if (!mouseControl)
      //break;
    if (angleController == 0) {
      System.out.println("YAW!");
      objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z, 5, 0, 0, 0, cubes);
    }
    else if (angleController == 1)
      objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z, 0, 5, 0, 0, cubes);
    else
      objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z, 0, 0, 5, 0, cubes);
    break;

  // Decrement angle value
  case 'z':
    if (!mouseControl)
      break;
    if (angleController == 0)
      objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z, -5, 0, 0, 0, cubes);
    else if (angleController == 1)
      objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z, 0, -5, 0, 0, cubes);
    else
      objects[selectedObject].translateObject(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y, objects[selectedObject].objectCenter.z, 0, 0, -5, 0, cubes);
    break;

  //STOP active control
  case 's': //stop
    for (int i = 0; i < nCubes; i++) {
      pose(i);
    }
    break;

  case 'd': // debugView
    debugView = !debugView;
    break;

  case ' ':
    myClient = new Client(this, "localhost", 8000); // reconnect
    break;
  default:
    break;
  }
}

/*
* This class is for the String Cube, the toio that is in charge of controlling the string length
*/

class StringCube extends Cube {
  ///**for determining rotation use **////
  float delta = 0.0;
  float deltaDegree = 0;
  int rotatedPreFrame = 0;
  int lastRotated = 0;

  StringCube (int i, boolean lost) {
    super(i, lost);
  }

  boolean rotateByHeight(int id, float need) {
    // need = the amount of degree rotation needed?
    // dir = direction of left or right rotation
    int dir = (need > 0) ? 1 : -1;
    float strength = need / 14; // used to be 14
    float left =  4 * (strength); // used to be 6
    float right = -4 * (strength);

    if (abs(need) < 3 || abs(left) < 10) return true; // used to be 3
    //println("motorControl:", need, left);

    float max = 70;
    //use map(value, 0, max, 0, 115)?
    if (abs(left) > max ) left = dir * max; // why max? why not 115? now: 60
    if (abs(right) > max ) right = -dir * max;

    int duration = 10; // used to be 100

    motorControl(id, left, right, duration);
    return false;
  }

  /*
  * This updates rotating vars when cube is still rotating
  */
  public void setAsRotating() {
    rotatedPreFrame = super.rotatedDeg - lastRotated; // note rotatedDeg is also updated in server_rece_cmd.pde
    lastRotated = super.rotatedDeg;

  }

  /*
  * This updates rotating vars when cube finished rotating
  */
  public void setAsCompleted() {
    super.rotatedDeg = 0;
    lastRotated = 0;
    super.rotationComplete = true;
  }
}

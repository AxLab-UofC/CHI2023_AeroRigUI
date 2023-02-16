class Cube {
  ///** variables used by server (DON'T CHANGE) **///
  int prex;
  int prey;
  float targetdeg = 0;
  float speedX;
  float speedY;
  boolean buttonState = false;
  boolean targetMode = false;
  boolean collisionState = false;
  boolean tiltState = false;
  long lastUpdate;
  int count=0;
  int aveFrameNum = 5;
  float pre_speedX[] = new float [aveFrameNum];
  float pre_speedY[] = new float [aveFrameNum];
  float ave_speedX;
  float ave_speedY;

  ////**general valuses we are using **////
  int id;
  boolean isLost = false;
  int x;
  int y;
  float targetx =-1;
  float targety =-1;
  int deg;
  int predeg; //previous frames deg
  boolean isFirstFrame = true;
  int rotatedDeg = 0; //cannot
  ////**for rotation use**////
  boolean rotationComplete = false;

  ////**for simulation init use**////
  int[] offset;
  boolean isPointSet = false;


// Constructor:
  Cube(int i, boolean lost) {
    id = i;
    isLost=lost;
    lastUpdate = System.currentTimeMillis();
    for(int j = 0; j< aveFrameNum; j++){
      pre_speedX[j] = 0;
      pre_speedY[j] = 0;
    }
  }

  int[] aim(float tx, float ty) {
    int left = 0;
    int right = 0;
    float angleToTarget = atan2(ty-y, tx-x);
    float thisAngle = deg*PI/180;
    float diffAngle = thisAngle-angleToTarget;

    if (diffAngle > PI) diffAngle -= TWO_PI;
    if (diffAngle < -PI) diffAngle += TWO_PI;


    //if in front, go forward and
    if (abs(diffAngle) < HALF_PI) {
      //in front
      float frac = cos(diffAngle);

      if (diffAngle > 0) {
        //up-left
        left = floor(100*pow(frac,2));
        right = 100;

      } else if (diffAngle< 0) {
        left = 100;
        right = floor(100*pow(frac,2));
      }


    } else {
      //face back
      float frac = -cos(diffAngle);
      if (diffAngle > 0) {
        left  = -floor(100*frac);
        right =  -100;
      } else {
        left  =  -100;
        right = -floor(100*frac);
      }
    }
    //println(left +" " + right);
    int[] res = new int[2];
    res[0] = left;
    res[1] = right;
    return res;
  }

  float distance(float ox, float oy) {
    return sqrt ( (x-ox)*(x-ox) + (y-oy)*(y-oy));
  }
/* --------------------------------------------------------------------------*/
/*                  Keep track of constant rotation                          */
/* ------------------------------------------------------------------------- */
  void rotatedDegUpdated(){
    //first frame no need
    if(isFirstFrame) {
      isFirstFrame = false;
      return;
    }

    //rotatedDeg Calculation
    int diff = deg - predeg;
    if(abs(diff)<3) diff = 0;
    if(diff>180) diff = diff - 360;
    if(diff<-180) diff = diff + 360;

    rotatedDeg += diff; //store new rotated degree
  }
}


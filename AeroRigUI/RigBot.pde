/*
* this class defines a two-toio stack
* this links a top toio with a bottom toio
*/

public class RigBot
{
    public int id;
    public Cube ceilingCube;
    public StringCube stringCube;
    private ConnectionPoint linkedPoint;
    float offsetX;
    float offsetY;
    // calibration variables
    boolean calibrated = false;
    private int stoppedFrames = 0;


/* -------------------------------------------------------------------------- */
/*              extra Variables for antiswing control                         */
/* -------------------------------------------------------------------------- */
    boolean finishMoving = false;
    boolean finishRotating = false;

    //** main flags before actual AntiSwing movement
    //based on new position to do the tranlation
    boolean startTrans = false;
    //after rotating the RigBot to aim to the traget coordinate, let RigBot move in straight line
    boolean ismoving = false;
    //based on the difference of current degee and target coordinate's degree
    boolean needrotating = true;
    //there's some latency when toio first receives the command from Processing, we need to skip toio's idle state
    int startempty = 0;

    //** main flags for AntiSwing motion planning
    boolean jerk = false;
    boolean cons = false;
    boolean damp = false;

    //** main variables for calculation
    float travel_dist = 0; //total travel distance
    float speed = 0; //RigBot's speed
    float real_max = 0; //RigBot's actual maximum speed if meets the requirement of anti-swing
    float dist_done = 0; //track how far RigBot goes during the movement
    float jerktime = 0; //the duration to perform the "jerk" period in acceleration phase, damptime == jerktime
    float jerk_dist = 0; //the distance to perform the "jerk" period in acceleration phase
    float acc_t = 0; //the duration to perform the "constant acceleration" period in acceleration phase
    float acc_dist = 0; //the distance to perform the "constant acceleration" period in acceleration phase
    float damp_dist = 0; //the distance to perform the "damp" period in acceleration phase
    float dec_t = 0; //the duration to perform the "constant deceleration" in deceleration phase
    float dec_dist = 0; //the distance to perform the "constant deceleration" in deceleration phase

    //** these two used for counting the real update frame/time, which will be used for calculating the speed at that moment
    float travelTime = 0;
    float lasttime = 0;


  /*
  * constructor
  * usage: RigBot(int id, Cube ceilingCube, Cube stringCube)
  */
  public RigBot(int id, Cube ceilingCube, StringCube stringCube)
  {
    this.id = id;
    this.ceilingCube = ceilingCube;
    this.stringCube = stringCube;
    this.linkedPoint = null;
    this.offsetX = 0;
    this.offsetY = 0;
    this.calibrated = false;


    this.finishMoving = false;
    this.finishRotating = false;
    this.startTrans = false;
    this.ismoving = false;
    this.needrotating = true;
    this.startempty = 0;
    //** main flags for AntiSwing motion planning
    this.jerk = false;
    this.cons = false;
    this.damp = false;
    //** main variables for calculation
    this.travel_dist = 0;
    this.speed = 0;
    this.real_max = 0;
    this.dist_done = 0;
    this.jerktime = 0;
    this.jerk_dist = 0;
    this.acc_t = 0;
    this.acc_dist = 0;
    this.damp_dist = 0;
    this.dec_t = 0;
    this.dec_dist = 0;
    this.travelTime = 0;
    this.lasttime = 0;

  }
/* -------------------------------------------------------------------------- */
/*                       Rigbot update functions                              */
/* -------------------------------------------------------------------------- */

  /*
    * ensures that the hypotenuse remains the same length
    * updates offsetX, offsetY based on the hypotenuse and objectCenter
    * @param  x:  cp.getCenter().x - objectCenter.x;
   */
  public void updateOffset(float offset, float x, float y) {
    if (x == 0 && y == 0) {
      offsetX = 0;
      offsetY = 0;
      return;
    }
    float hypotenuse = sqrt(x * x + y * y);
    // calculate offsetX and offsetY with theta and offset value
    offsetX = offset * x/hypotenuse;
    offsetY = offset * y/hypotenuse;
  }

  /*
  * This updates the (x,y,z) of the bot to the target coords based on new (x,y,z), stringAngle and newoffset
  */
  public void updateXYZ(Point targetPoint, float offset){
    if (simControl) {
      updateSimXYZ(targetPoint);
      return;
    }

    //will only pass the assigned cubes data here to update them
    pushMatrix();
    // update XY of the ceiling bot by x,y-coords changes
    if (!ceilingCube.isLost) {
      ceilingCube.targetx = targetPoint.x + offsetX;
      ceilingCube.targety = targetPoint.y + offsetY;
    }
    // update the string bot by z-coord changes
    if (!stringCube.isLost) {
      float targetStrlen = sqrt(sq(targetPoint.z - botHeight) + sq(offset));
      if(targetStrlen< mmToToio) targetStrlen = 0;
      stringCube.delta = - linkedPoint.strlen + targetStrlen; //+ down, - up
      if(abs(stringCube.delta)> 0){
        stringCube.rotationComplete = false;
        stringCube.deltaDegree = stringCube.delta/spinR;
      }
    }
    popMatrix();
  }

/* -------------------------------------------------------------------------- */
/*                       Rigbot move functions                                */
/* -------------------------------------------------------------------------- */
  /*
  *   move the ceiling cube according to target x and target y
  */
  public void translateCeilingCube(){
    if (ceilingCube.isLost) {
      pose(ceilingCube.id);
      return;
    }
    moveRigBot(this.id, ceilingCube.targetx, ceilingCube.targety, max_user_speed);
  }

  /*
  *   executes rotation of the string cube
  *   ensures rotation completes and updates string length if calibrating
  */
  public void rotateStringCube(float offset) {
    if (stringCube.isLost) {
      pose(stringCube.id);
      return;
    }

    if(!stringCube.rotationComplete) {
      // rotateByHeight returns true if rotation is complete
      if(stringCube.rotateByHeight(stringCube.id, stringCube.deltaDegree)) {
        stringCube.setAsCompleted();
        linkedPoint.strlen = sqrt(sq(linkedPoint.getCenter().z -botHeight) + sq(offset)); // computes the expected strlen
        println("finish rotating!"+linkedPoint.strlen);
        return;
      }
      // if rotation is not complete
      stringCube.setAsRotating();
      // println("rig bot rotatedDeg: " + cubes[1].rotatedDeg);
      linkedPoint.strlen += stringCube.rotatedPreFrame * spinR;
      // println("linkedPoint.strlen: " + linkedPoint.strlen + ", stringCube.rotatedPreFrame: " + stringCube.rotatedPreFrame);
    }
  }


/* -------------------------------------------------------------------------- */
/*                       Rigbot simulation functions                          */
/* -------------------------------------------------------------------------- */

  /*
  * This updates the x,y,z of the connection point to the target coords in simulation
  * this only updates for translation, no rotation changes
  */
  private void updateSimXYZ(Point targetPoint){
    // if (ceilingCube.isLost) {
    //   return;
    // }
    pushMatrix();
    ceilingCube.targetx = targetPoint.x + offsetX;
    ceilingCube.targety = targetPoint.y + offsetY;
    popMatrix();
  }
  /*
  *   simulate the ceiling cube according to target x and target y
  */
  public void simulateBots(int x, int y){
    if(ceilingCube.id < cubes.length){
      ceilingCube.count++;
      // constant speed for simulation, IRL speed is derived from the real-world speed of the cube
      ceilingCube.speedX = speed;
      ceilingCube.speedY = speed;
      ceilingCube.x = x;
      ceilingCube.y = y;
      ceilingCube.lastUpdate = System.currentTimeMillis();
    }
    ceilingCube.isLost = false;
  }

  public void simuTranslate(){
    // simulate cube moving at constant speed

    float elapsedTime = System.currentTimeMillis() -  ceilingCube.lastUpdate;

    float targetX = ceilingCube.targetx;
    float targetY = ceilingCube.targety;
    float[] velocity = new float[2];
    velocity = calculateVelocity(targetX, targetY);

    float distx =  velocity[0] * elapsedTime / 1000;
    float disty =  velocity[1] * elapsedTime / 1000;

    if (abs(targetX - ceilingCube.x) < deadZone) distx = 0;
    if (abs(targetY - ceilingCube.y) < deadZone) disty = 0;

    float xFinal = ceilingCube.x + distx;
    float yFinal = ceilingCube.y + disty;

    simulateBots(int(xFinal), int(yFinal));
  }


/* -------------------------------------------------------------------------- */
/*                         Calibration functions                              */
/* -------------------------------------------------------------------------- */
  /*
  * this function retracts the string all the way to the top,
  * and stops when the string is retracted all the way
  */
  void retractToTop(){
    if (stringCube.isLost) {
      return;
    }

    motorControl(stringCube.id, -50, 50, 100);
    stringCube.setAsRotating();

    //count how many stopped frames
    if(stringCube.rotatedPreFrame == 0) {
      stoppedFrames++;
    } else {
      stoppedFrames = 0;
    }

    // stop after 20 stopped frames to prevent random stopped frames
    if(stoppedFrames >= 20) {
      println("stopped");
      playSound(stringCube.id, 100, 100, 150);
      stringCube.rotationComplete = false;
      resetVariables();
    }
  }

  void resetVariables() {
    stringCube.isFirstFrame = true;
    stringCube.rotatedDeg = 0;
    stringCube.lastRotated = 0;
    stringCube.rotationComplete = false;
    linkedPoint.strlen = 0;
    calibrated = true;
  }


/* -------------------------------------------------------------------------- */
/*             getter, setter, and helper functions                           */
/* -------------------------------------------------------------------------- */
  public ConnectionPoint getLinkedPoint(){
    if (this.linkedPoint == null)
    {
      return null;
    }
    return this.linkedPoint;
  }

  public void setLinkedPoint(ConnectionPoint linkedPoint){
    this.linkedPoint = linkedPoint;
  }

  public Cube[] getCubes() {
    return new Cube[] { ceilingCube, stringCube };
  }

  boolean checkLostBot() {
    if (ceilingCube.isLost || stringCube.isLost) {
      println("Lost: RigBot"+this.id);
      return true;
    }
    return false;
  }

  /*
  * for simulation use
  */
  private float[] calculateVelocity(float targetX, float targetY){
    float angle = atan2(targetY - ceilingCube.y, targetX - ceilingCube.x);
    //somehow speedX and speedY can't update in simubots()
    float vx = abs(cos(angle) * 200);
    float vy = abs(sin(angle) * 200);

    if (targetY < ceilingCube.y) vy = -vy;
    if (targetX < ceilingCube.x) vx = -vx;
    return new float[]{vx, vy};
  }

  /*
  * main calculation function to get all needed variables to perform Anti-Swing
  * all units would be millimeter(mm) and second(s)
  * based on the StringLength (l), the maximumSpeed(speed)
  */

  public void calculateAntiSwing( float maxspeed){

    //max swing theta in the end we wish to have
    float theta_min = 2*degree;

    //** This method is built upon the theroy which only considers a fixed string length. In the real scenario, there would be two plans to get the string length.
    //plan 1: go with current stringlength (the current z)
    //float strlen = this.linkedPoint.strlen;

    //plan 2: go with future stringlength (the target z)
    float strlen = linkedPoint.getCenter().z -botHeight; //h is the height of RigtBot

    float v_max = maxspeed; // in mm/s

    float a_a = 70; //the desired acceleration rate of toio we want in mm/s^2
    float a_max = 200; //the max acceleration rate of toio in mm/s^2

    //the duration to perform the "jerk" part in acceleration phase
    float t_j_max= PI*sqrt(2*a_a*strlen/mmToToio)/sqrt(g*1000*a_max);
    this.jerktime = t_j_max;

    //parameters of angular speed and acceleration
    float k, w;
    w = 2*PI/t_j_max;
    k = 2*PI*theta_min / sq(t_j_max);

    //** JERK period
    float a_j_max = k*strlen*sin(w*t_j_max*1/4)
                    - g*1000*mmToToio*k*sin(w*t_j_max*1/4)/sq(w)
                    + g*1000*mmToToio*k*t_j_max*1/4/w;
    //println("a_j_max:" +a_j_max + "mm/s2");

    // based on the sinusoidal curve of acceleration rate, we could estimate the Max speed during that peroid by calculating the area of traiangle.
    float v_j_max = a_j_max * t_j_max*1/2 *1/2;
    //println("v_j_max:" +v_j_max + "mm/s");

    // based on the curve of speed, we could estimate the Max distance during that peroid by calculating the the area of traiangle.
    this.jerk_dist = v_j_max * t_j_max *1/2;
    //println("s_j_max:" +s_j_max + "mm");

    //** Constant Acceleration peroid
    float t_acc =v_max/a_a- t_j_max;
    this.acc_t = t_acc;
    //println("tc:" +t_acc + "s");

    //estimate that distance by calculating the area of trapezoidal
    this.acc_dist = (v_max + 22.5)*t_acc *1/2 ;
    //println("s_c_max:" +s_c_max + "mm");

    //** DAMP peroid
    float a_d_max = a_j_max;

    // based on the cosusoidal curve of acceleration rate, we could estimate the Min speed during that peroid by calculating the area of traiangle.
    float v_d_min = v_max - a_d_max * t_j_max*1/2 *1/2;
    //println("v_d_max:" +v_d_max + "mm/s");

    // based on the curve of speed, we could estimate the Max distance during that peroid by calculating the the difference between area of rectangle and area of traiangle.
    this.damp_dist = t_j_max * v_max - v_d_min * t_j_max *1/2;
    //println("s_d_max:" +s_d_max + "mm");

    //println("s_acc:" + (s_j_max+s_c_max+s_d_max));

    //** Deceleration phase
    float t_dec_max = 2*v_max / (g*1000*mmToToio*theta_min);
    this.dec_t = t_dec_max;
    //println("t_dec_max:" + (t_dec_max));

    //toio sensor would agree with a 15 error when reaching the target coordinate
    this.dec_dist = v_max * t_dec_max *1/2 + 15/mmToToio;
    //println("s_dec:" + s_dec);
  }


  /*
  * Function to calculate the acceleration rate at specific moment (time)
  * based on the travelTime(t) in the sinusoidal/cosusoidal curve
  */

  public float acc_j_d(float t){
    float acc;

    float a_a = 70; // mm/s2
    float a_max = 200; // mm/s2
    //plan 1: go with current stringlength
    //float strlen = this.linkedPoint.strlen;

    //plan 2: go with future stringlength
    float strlen = linkedPoint.getCenter().z -botHeight;

    float theta_min = 2*degree;
    float t_j_max = PI*sqrt(2*a_a*strlen/mmToToio)/sqrt(g*1000*a_max);
    float k, w;
    w = 2*PI/t_j_max;
    k = 2*PI*theta_min / sq(t_j_max);

    acc = k*strlen*sin(w*t)
          - g*1000*mmToToio*k*sin(w*t)/sq(w)
          + g*1000*mmToToio*k*t/w;

    return acc;
  }

}

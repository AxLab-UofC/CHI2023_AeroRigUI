/*
 * This class defines a 3D object in space
 * Constructor: id: id of object
*/

public class Object
{
  public int id;
  public ConnectionPoint connections[];
  public ConnectionPoint deFaultConnections[];
  public Point objectCenter; // Center of mass of object
  public float maxZ = Float.MAX_VALUE; // Largest Z value possible

  public float yaw;
  public float pitch;
  public float roll;
  public float newyaw;
  public float newpitch;
  public float newroll;
  public float[] initCoords;
  public boolean objectCalibrated = false;
  public float stringAngle; // angle between string and ceiling surface in degrees. Perpendicular = 90.
  public float offset;

  // Constructor
  public Object(int id, ConnectionPoint connections[]){

    this.id = id;
    this.deFaultConnections = connections;
    this.connections = connections;
    this.maxZ = maxZ;

    //set default rotations
    this.yaw = 0;
    this.pitch = 0;
    this.roll = 0;

    this.objectCenter = computeObjectCenter(this.connections);
    this.stringAngle = 0;
    this.offset = 0;
  }

/* -------------------------------------------------------------------------- */
/*                              helper funtions                               */
/* -------------------------------------------------------------------------- */
  // get center position
  private Point computeObjectCenter(ConnectionPoint[] cps) {
    float x_total = 0;
    float y_total = 0;
    float z_total = 0;

    for (ConnectionPoint c : cps)
    {
      x_total += c.getCenter().x;
      y_total += c.getCenter().y;
      z_total += c.getCenter().z;
      // this.maxZ = min(maxZ, c.strlen + h);
      this.maxZ = 1500;
    }
    return new Point(x_total / float(cps.length), y_total / float(cps.length), z_total / float(cps.length));
  }
  // pause cubes
  public void poseAllCubes(){
    for (Cube cube : cubes) {
      pose(cube.id);
    }
  }

/* -------------------------------------------------------------------------- */
/*                            main drive funtion                              */
/* -------------------------------------------------------------------------- */
  public void translateObject(float newx, float newy, float newz, float newyaw, float newpitch, float newroll, float newStringAngle, Cube cubes[]){
    //outside is (getValue - this.value), so do this ++
    if(abs(newyaw) > 5) this.yaw += newyaw;
    if(abs(newpitch) > 5) this.pitch += newpitch;
    if(abs(newroll) > 5) this.roll += newroll;

    float distx = newx - objectCenter.x;
    float disty = newy - objectCenter.y;
    float distz = newz - objectCenter.z;
    //println("delta:"+distz +"new:"+newz +"obj:"+objectCenter.z );

    //update new positions
    this.objectCenter.x = newx;
    this.objectCenter.y = newy;
    this.objectCenter.z = newz;

    // update new string angle
    this.stringAngle = radians(newStringAngle);

    // update connection points linked to this object
    for (ConnectionPoint c : this.connections)
    {
      RigBot bot = c.bot;

      // updates coordinates using distx,y,z, newyaw, pitch, roll and objectCenter
      c.translatePoint(distx, disty, distz);
      c.rotatePoint(newyaw, newpitch, newroll, this.objectCenter);

      // x, y distances from object center
      float x = c.getCenter().x - this.objectCenter.x;
      float y = c.getCenter().y - this.objectCenter.y;

      this.offset = this.objectCenter.z * tan(this.stringAngle);
      bot.updateOffset(this.offset, x, y);
      //updates the matrices of the rigbot based on 6 dof changes
      bot.updateXYZ(c.getCenter(), this.offset);

      if (simControl){
        bot.simuTranslate();
      } else {
        bot.translateCeilingCube();
        bot.rotateStringCube(this.offset);
      }
    }
  }



/* -------------------------------------------------------------------------- */
/*                          Calibration funtions                              */
/* -------------------------------------------------------------------------- */
  public void calibrate() {
    //need to reset the postion values (yaw, pitch, roll and stringAngle)
    this.translateObject(this.objectCenter.x, this.objectCenter.y, this.objectCenter.z, 0, 0, 0, 0, cubes);
    int calibratedBots = 0;
    // calibrate each rigbot
    for (ConnectionPoint cp: connections) {
        //* (Added) if bots go back position do calibration
        if(!cp.bot.finishMoving && cp.bot.stringCube.rotationComplete){
            cp.bot.retractToTop();
            if(cp.bot.calibrated) {
                calibratedBots++;
            }
        }
    }
    //println(calibratedBots);
    if(calibratedBots >= connections.length) {
      // retraction is complete, set connection points at initPoint at h/2
      this.connections = deFaultConnections;
      this.objectCenter = computeObjectCenter(deFaultConnections);
      this.offset = 0;
      this.yaw = 0;
      this.pitch = 0;
      this.roll = 0;

      setControls();

      this.objectCalibrated = true;
      calibrateControl = false;
      println("Object calibrated");
    }
  }

  //TODO: use real offst value
  int getOffset() {
    int aveDist = 0;
    for (int d : dist) {
      aveDist += d;
    }
    aveDist /= dist.length;
    // offset = (int) aveDist / 4;
    offset = 100;
    return aveDist;
  }

  void setControls() {
    objectXYControl.setValue(objectCenter.x, objectCenter.y);
    zControl.setValue(objectCenter.z);
    yawControl.setValue(yaw);
    pitchControl.setValue(pitch);
    rollControl.setValue(roll);
    stringAngleControl.setValue(stringAngle);
    mouseControl = true;
    mouseToggle.setValue(false);
  }
}

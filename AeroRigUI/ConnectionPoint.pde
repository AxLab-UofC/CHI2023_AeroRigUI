/*
 * This class defines a connection point for an object in space
 * each connection point is mapped one-to-one to a RigBot
 * connection points are instantiated using existing connection points and distances from each other
*/
//https://happycoding.io/tutorials/java/inheritance

// Connection point for a cube.

///** TEMPLATE (because different move types) **///
public class ConnectionPoint {
  public int id;
  public Point center;
  public RigBot bot; // the bot that this connection point is linked to; null if not linked
  public float strlen;  // String length

/*
* This instantiates a connection point from an arbitrary point
* @param point determines the center of the connection point
*/
  public ConnectionPoint(int id, Point point, RigBot bot)
  {
    this.id = id;
    this.center = point;
    this.bot = bot;
    this.bot.setLinkedPoint(this);
    this.strlen = 0;
  }

/*
* This instantiates a connection point a horizontal distance from an existing connection point
* @param dist determines the distance from the existing connection point
*/
  public ConnectionPoint(int id, ConnectionPoint cp, int dist, RigBot bot)
  {
    this.id = id;
    this.center = new Point(cp.center.x + dist, cp.center.y, initPoint.z); // assume string is wound up all the way (z = hs)
    this.bot = bot;
    this.bot.setLinkedPoint(this);
    this.strlen = 0;
  }

  /*
  * This instantiates a connection point from two existing HORIZONTAL connection points
  * @param dist1 determines the distance from the cp1 to the new cp
  * @param dist2 determines the distance from the cp2 to the new cp
  *           [X] current cp
  *           / \
  *          /   \  dist 2
  *   dist1 /     \
  *        /       \
  *  cp1 [X]-------[X] cp2 (cp2 must be to the RIGHT of cp1)
  */
  public ConnectionPoint(int id, ConnectionPoint cp1, ConnectionPoint cp2, int dist1, int dist2, RigBot bot)
  {
    // TODO: can try to apply this to not horizontal connection points, need to transform coords onto new axis [ too tired rn :< ] )
    this.id = id;
    this.bot = bot;
    this.bot.setLinkedPoint(this);
    this.strlen = 0;

    float d = cp2.center.x - cp1.center.x; // distance between cp1 and cp2
    float x = (sq(d) - sq(dist2) + sq(dist1)) / (2 * d);
    float y = cp2.center.y + sqrt(sq(dist1) - sq(x));

    this.center = new Point((int)x + cp1.center.x, (int) y, initPoint.z);
  }

  ///*** getters and setters ***///

  public Point getCenter()
  {
    return this.center;
  }

  public RigBot getBot()
  {
    return this.bot;
  }

  ///*** methods ***///

  public void translatePoint(float distx, float disty, float distz)
  {
    this.center.translate(distx, disty, distz);
  }

  public void rotatePoint(float newyaw, float newpitch, float newroll, Point pivot)
  {
    //println(newpitch);
    if(abs(newyaw) > 5) {
      this.center.yaw(pivot.x, pivot.y, pivot.z, radians(newyaw));
    }
    if(abs(newpitch) > 5) {
      this.center.pitch(pivot.x, pivot.y, pivot.z, radians(newpitch));
    }
    if(abs(newroll) > 5) {
      this.center.roll(pivot.x, pivot.y, pivot.z, radians(newroll));
    }
  }
}

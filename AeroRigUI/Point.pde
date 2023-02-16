/*
 * This class defines a 3D point in space
 * Methods are provided to translate and rotate the point
*/

class Point {
  public float x = 0;
  public float y = 0;
  public float z = 0;

  // Constructor
  public Point(float x, float y, float z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

/*
* Translate the point by the given amouns
* @param x the amount to translate in the x direction
* @param y the amount to translate in the y direction
* @param z the amount to translate in the z direction
*/
  public void translate (float x, float y, float z)
  {
    this.x += x;
    this.y += y;
    this.z += z;
  }

/*
* Counterclockwise rotation about z-axis, angle is between 0 and ~6.28
* @param cx, cy, cz the center of the rotation
* @param angle the angle of the rotation
*/
  public void yaw (float cx, float cy, float cz, float angle)
  {
    float x = this.x - cx;
    float y = this.y - cy;
    float z = this.z - cz;
    float dx, dy, dz;
    // multiplication by 3x3 rotation matrix
    dx = (x * cos(angle)) + (y * sin(angle));
    dy = -(x * sin(angle)) + (y * cos(angle));
    dz = z;
    this.x = dx + cx;
    this.y = dy + cy;
    this.z = dz + cz;
  }

  // Counterclockwise rotation about y-axis, angle is between 0 and ~6.28
  public void pitch(float cx, float cy, float cz, float angle)
  {
    float x = this.x - cx;
    float y = this.y - cy;
    float z = this.z - cz;
    float dx, dy, dz;
    dx = x;
    dy = (y * cos(angle)) + (z * sin(angle));
    dz = -(y * sin(angle)) + (z * cos(angle));
    this.x = dx + cx;
    this.y = dy + cy;
    this.z = dz + cz;
  }

  // Counterclockwise rotation about x-axis, angle is between 0 and ~6.28
  public void roll(float cx, float cy, float cz, float angle)
  {
    float x = this.x - cx;
    float y = this.y - cy;
    float z = this.z - cz;
    float dx, dy, dz;
    dx = (x * cos(angle)) + (z * sin(angle));
    dy = y;
    dz = -(x * sin(angle)) + (z * cos(angle));
    this.x = dx + cx;
    this.y = dy + cy;
    this.z = dz + cz;
  }
}

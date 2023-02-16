///** MAIN function to visualize everything **///
void displayDebug() {
  background(0);
  stroke(255);

  if (!enable3Dview) {
    fill(255);
    textSize(12);
    text("FPS = " + frameRate, 10, height-10);//Displays how many clients have connected to the server
    // display 2D
    //display2D();
  } else {
    if (keyPressed && key == ' ') {
      cam.setMouseControlled(true);
    } else {
      cam.setMouseControlled(false);
    }
    // display 3D
    display3D();

    cam.beginHUD();
    if (debugView) {
      debugFor3DView();
    }
    cam.endHUD();
  }
}


/* --------------------------------------------------------------------------*/
/*                               Display 3D                                  */
/* ------------------------------------------------------------------------- */
///** function to show everything in 3D **///
void display3D() {
  //stage lets see how to roate it together
  pushMatrix();
  rotateX(radians(30));
  rotateX(radians(250));
  translate(0, 0, -300);
  drawMainStage();
  //Axis
  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);
  drawAxis();

  //cubes
  if(!combinedMode){
    for (int i = 0; i < nCubes; i++) {
      renderToio(i);
    }
  } else{
    renderRigBots();
  }

  // Drawing targets and string lines
  for (int i = 0; i < nObjects; i++) {

    boolean highlight = false;
    if (i == selectedObject)
    {
      highlight = true;
    }

    // draw target object
    drawTarget3D(i, objects[i].objectCenter.x, objects[i].objectCenter.y, objects[i].objectCenter.z, highlight);

    //draw string lines and attachment plane
    stroke(255, 255, 255, 100); // define stroke color (R,G,B, alpha) -- all between 0-255
    strokeWeight(5);

    for (ConnectionPoint p : objects[i].connections)
    {
      line(p.bot.ceilingCube.x, p.bot.ceilingCube.y, botHeight, p.getCenter().x, p.getCenter().y, p.getCenter().z);

      for (ConnectionPoint q : objects[i].connections) {
        if (q.id > p.id){
          line(q.getCenter().x, q.getCenter().y, q.getCenter().z, p.getCenter().x, p.getCenter().y, p.getCenter().z);
        }
      }
    }
  }
  popMatrix();
  popMatrix();
}

///** Debug info **///
void debugFor3DView() {
  //control GUI
  cp5.draw();
  //safety GUI
  cpSafety.draw();

  fill(255);
  textSize(20);
  text("Hold 'SPACE' + Drag to Rotate the 3D Model \nHold 'd' to remove the debug view. \nSelected object: " + selectedObject, 20, 30);
}


/* --------------------------------------------------------------------------*/
/*                            DRAWING METHODS                                */
/* ------------------------------------------------------------------------- */
//draw object at (x,y,z) method
void drawTarget3D(int id, float x, float y, float z, boolean selected) {
  pushMatrix();
  translate(x, y, z);
  if (selected) {
    fill(255, 0, 0);
  }
  else {
    fill(0, 0, 255);
  }
  noStroke();
  sphere(10);
  textSize(12);
  rotateX(radians(90));
  text("3D target " + id + " [" + x + ", " + y + ", " + z + "]", 15, 0);
  popMatrix();
}

//draw toios and inBetweenMats togeter
void renderRigBots(){
  for(RigBot bot: bots){
    if(!bot.checkLostBot()){
      int id = bot.id;
      Cube ceiling = bot.ceilingCube;
      Cube string = bot.stringCube;
      drawToio(ceiling.id, ceiling.x, ceiling.y, ceiling.deg);
      drawCylinder(id, ceiling.x, ceiling.y, ceiling.deg);
      pushMatrix();
      translate(0, 0, 25);
      drawToio(string.id, ceiling.x, ceiling.y, string.deg);
      popMatrix();

    }
  }
}

void drawToio(int id, float x, float y, float deg) {
  pushMatrix();
  stroke(200);
  strokeWeight(1);
  fill(255);
  translate(x, y, 10);
  rotate(radians(deg));
  box(23, 23, 19);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(13, 0, 10, 5, 0, 10);
  popMatrix();
}

void drawCylinder(int id, float x, float y, float deg){
    pushMatrix();
    translate(x, y, 23);
    rotate(radians(deg));
    renderCylinder(100, 17, botHeight);
    popMatrix();
}

void renderCylinder(int sides, float r, float h){
    float angle = 360 / sides;
    float halfHeight = h / 2;
    int offset = 23;
    // draw top shape
    beginShape();
    stroke(255, 255, 255, 80);
    noFill();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, 0 - offset);
    }
    endShape(CLOSE);
    // draw bottom shape
    beginShape();
    stroke(255, 255, 255, 80);
    noFill();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, h - offset);
    }
    endShape(CLOSE);
    // draw body
    beginShape(TRIANGLE_STRIP);
    stroke(255, 255, 255, 80);
    tint(255, 70);
    // noFill();
    for (int i = 0; i < sides + 1; i++) {
        float x = cos( radians( i * angle ) ) * r;
        float y = sin( radians( i * angle ) ) * r;
        vertex( x, y, h - offset);
        vertex( x, y, 0 - offset);
    }
    endShape(CLOSE);
}

//render toio boxes in the scene
void renderToio(int toioID) {

  int x = cubes[toioID].x, y = cubes[toioID].y, deg = cubes[toioID].deg;
  pushMatrix();

  //based on status
  if (cubes[toioID].isLost) {
    stroke(200, 50);
    fill(255, 50);
  } else {
    stroke(200);
    fill(255);
  }

  strokeWeight(1);
  translate(x, y, 10);
  /*
  if(toioID % 2 == 0){
    translate(x, y, 10);
    line(13, 0, 10, 5, 0, 10);
  }else{
    translate(x, y, 40);
    line(13, 0, 40, 5, 0, 40);
  }
  */
  rotate(radians(deg));
  box(23, 23, 19);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(13, 0, 10, 5, 0, 10); //direction
  popMatrix();
}

//render stage plane
void drawMainStage() {
  noStroke();
  fill(MainStageColor);

  PShape s = createShape();
  s.beginShape();

  // Exterior part of shape drawing lines to form a rect
  s.vertex(-stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, -stageDepth/2);

  // Finishing off shape
  s.endShape();

  shape(s);

  //start to do translation
  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);
  stroke(255, 30);
  for (int i = 0; i < 3; i++) {
    line(stageWidthMax/3 * (i+1), 0, stageWidthMax/3 * (i+1), stageDepthMax);
  }
  for (int i = 0; i < 4; i++) {
    line(stageWidthMax, stageDepthMax/4 * (i+1), 0, stageDepthMax/4 * (i+1));
  }

  fill(255, 20);

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
      int matID = 1 + (j) + i*4;
      text("#" + matID, stageWidthMax/3 * (i), stageDepthMax/4 * (j)+50);
    }
  }

  //finish doing translations
  popMatrix();
}

//render scene axis
void drawAxis() {
  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, 1000, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 1000, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 1000);
}

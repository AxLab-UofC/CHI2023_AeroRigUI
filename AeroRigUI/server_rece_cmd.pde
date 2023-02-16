//OSC message handling (receive)
int lastdeg = 0;

void serverReceive() {
  if (myClient.available() > 0) {

    String data = myClient.readString();
    //println(data);
    processClientMessage(data);
  }
}

void processClientMessage(String msg) {
  String[] s = split(msg, "\n");

  for (int i = 0; i<s.length; i++) {
    String[] m = split(s[i], "::");
    if (m[0].intern() == ("pos").intern() && m.length > 4) { //get position (x, y, and deg)
      //if (pcount != count) {

      int id = int(m[1]);
      int x = int(m[2]);
      int y = int(m[3]);
      int deg = int(m[4]);

      if (id < nCubes) {

        if (id < cubes.length) {
          cubes[id].count++;

          float elapsedTime = System.currentTimeMillis() -  cubes[id].lastUpdate ;

          if (elapsedTime != 0) {
            cubes[id].speedX = 1000.0 * float(cubes[id].x - cubes[id].prex) / elapsedTime;
            cubes[id].speedY = 1000.0 * float(cubes[id].y - cubes[id].prey) / elapsedTime;

            // if(cubes[0].speedX > 0)
            //     println("speedtop:" + cubes[0].speedX + "time:" + elapsedTime);
            //println("speedbottom:" + cubes[1].speedX);


            cubes[id].prex = cubes[id].x;
            cubes[id].prey = cubes[id].y;

            cubes[id].x = x;
            cubes[id].y = y;


            cubes[id].predeg = cubes[id].deg;
            cubes[id].deg = deg;

            cubes[id].lastUpdate = System.currentTimeMillis();

            float sumX = 0, sumY = 0;
            for (int j = 0; j < cubes[id].aveFrameNum-1; j++) {
              cubes[id].pre_speedX[cubes[id].aveFrameNum -1 - j] = cubes[id].pre_speedX[cubes[id].aveFrameNum -j -2];
              cubes[id].pre_speedY[cubes[id].aveFrameNum -1 - j] = cubes[id].pre_speedY[cubes[id].aveFrameNum -j -2];
              sumX += cubes[id].pre_speedX[cubes[id].aveFrameNum -1 - j];
              sumY += cubes[id].pre_speedY[cubes[id].aveFrameNum -1 - j];
            }


            sumX +=  cubes[id].speedX;
            sumY +=  cubes[id].speedY;

            cubes[id].pre_speedX[0] = cubes[id].speedX;
            cubes[id].pre_speedY[0] = cubes[id].speedY;


            cubes[id].ave_speedX = sumX / float(cubes[id].aveFrameNum);
            cubes[id].ave_speedY = sumY / float(cubes[id].aveFrameNum);

            // if(bots[0].ismoving){
            //     println("ave_speedX:" + cubes[0].ave_speedX);
            //     println("ave_speedY:" + cubes[0].ave_speedY);
            // }


             //System.out.println(String.format("nowdegree %d, last %d ", cubes[1].deg, cubes[1].predeg));
            cubes[id].rotatedDegUpdated();
          }

          //println(cubes[id].ave_speedX, cubes[id].ave_speedY);
        }
        cubes[id].isLost = false;
      }
    } else if (m[0].intern() == ("but").intern() && m.length > 1) {  //get button input 0 or 1
      // button


      int id = int(m[1]);
      int pressValue = int(m[2]);//ID, buttonState

      if (id < nCubes) {
        println("[App Message] Button pressed for id : "+id + ", val = " + pressValue);
        if (pressValue == 1) {
          cubes[id].buttonState = false;
        } else {
          cubes[id].buttonState = true;
        }
      }
    } else if (m[0].intern() == ("acc").intern() && m.length > 3) {
      // acc
      int id = int(m[1]);
      int isFlat = int(m[2]);
      //int orientation = msg.get(2).intValue();
      int collision = int(m[3]);

      //turn off collision for now'

      /*if (id < nCubes) {
        if (collision == 1) {
          println("[App Message] Collision Detected for id : " + id );

          cubes[id].collisionState = true;
        }

        if (isFlat == 1) {
          cubes[id].tiltState = true;
        } else {
          cubes[id].tiltState = false;
        }
      }*/
    }
  }
}

/* -------------------------------------------------------------------------- */
/*           Main move RigBot functions, including AntiSwing method           */
/* -------------------------------------------------------------------------- */

/** main function entry **/
void moveRigBot(int botID, float tx, float ty, float max) {
  //mark all needed variabels
  RigBot rigbot = bots[botID];
  int id = rigbot.ceilingCube.id;

  PVector target = new PVector(tx,ty);
  //first rotate to traget, make the Rigbot aim the traget direction
  //if input new position is different from the last position point, we update the loop toggles
    if(lastPoint[botID].dist(target)>10){
        rigbot.finishMoving = false;
        rigbot.startTrans = true;
        rigbot.ismoving = false;
        rigbot.needrotating = true;
        lastPoint[botID] = target;
    }

    if(rigbot.startTrans){
        //prepare to rotate ( this part is mainly from old aimCube() function)
        float angleToTarget = atan2(ty-cubes[id].y, tx-cubes[id].x);
        float thisAngle = cubes[id].deg*PI/180;
        float diffAngle = thisAngle-angleToTarget;
        if (diffAngle > PI) diffAngle -= TWO_PI;
        if (diffAngle < -PI) diffAngle += TWO_PI;

        //rotate to aim to target
        if(rigbot.needrotating){

            //this return should be considered carefully, otherwise it won't trigger moveto()
            if(int(abs(diffAngle/degree)) <= 9){

                //** variables for antiswing
                bots[botID].travelTime = 0;
                //processing and toio communication has some latancy at first time, so we need to skip these frames
                rigbot.startempty = 0;

                //the target distance need travel (unit in mm)
                rigbot.travel_dist = cubes[id].distance(tx, ty) / mmToToio;

                //the real max speed in the given constrains, by default, it should be the max we want
                rigbot.real_max = max*2.25;

                //the main step to calculate the distances for each part of the trajectory
                //this one will be re-calculate if the DEC distanc is too long while in the move phase
                //Since UpdateXYZ happens before this, Rigbot has updated it's string length already, so it's good to use
                //which means if the target position is lower than the starting point, it will use the longer one to calculate the acc,
                //righ now it can't adjust the speed or acc during the movment based on the chaning string length.
                rigbot.calculateAntiSwing(rigbot.real_max);

                //** variables for ACC phase:
                rigbot.jerk = false;
                rigbot.cons = false;
                rigbot.damp = false;

                rigbot.ismoving = true;
                rigbot.needrotating = false;
                println("rotate finished!!!!" + rigbot.travel_dist);

            } else {
                //not sure how to use the last two variables in this case.
                rotateTo(id, int((thisAngle-diffAngle)/degree), 0, 10);
            }
        }

        if(rigbot.ismoving){
            //original method
            if(original_moveto){
                moveTo(rigbot.ceilingCube.id, int(tx), int(ty), 200, 10);

                if(lastPoint[botID].dist(target)<10){
                    rigbot.startTrans = false;
                    rigbot.finishMoving = true;
                    println("finished moving!!!");
                }
            }

            //Anti-sway method
            if(antisway_moveto){
                if(antiSwing(botID, id, tx, ty, diffAngle, max)){
                    rigbot.startTrans = false;
                    rigbot.finishMoving = true;
                    //reset all variables/ flags
                    rigbot.travel_dist = 0;
                    rigbot.jerk_dist = 0;
                    rigbot.acc_dist = 0;
                    rigbot.damp_dist = 0;
                    rigbot.dec_dist = 0;
                    rigbot.lasttime = 0;

                    println("finished moving!!!");
                    rigbot.finishMoving = true;
                }
            }

        }
    }

}



boolean antiSwing(int botID, int id, float tx, float ty, float diffAngle, float max){

    //mark useful variables
    RigBot rigbot = bots[botID];

    //both in mm
    float distanceRemain = cubes[id].distance(tx, ty) / mmToToio;
    float distanceDone = rigbot.travel_dist - distanceRemain;

    //** paramaters for tiny Adjusting directions while moving
    float a = 1;
    float b = 1;
    if(cubes[id].distance(tx, ty) >=10){
        float frac = cos(diffAngle);
        if (diffAngle > 0) {
        //up-left
            a = pow(frac,2);
            b = 1;
        } else if (diffAngle< 0) {
            a = 1;
            b = pow(frac,2);
        } else if(diffAngle == 0){
            a= 1;
            b= 1;
        }
    } else {
        a=1;
        b=1;
    }

    //speed range check:
    //becasue Deceleration(dec) is the most important part, we need to first satisify that distance(sometimes dec will be longer than total travel distance after 1st round calculation). In order to make the system efficient(at lease have half acc phase, half dec phase), we can re-calculate the max speed based on the desired dec distance
    if((rigbot.dec_dist + rigbot.damp_dist) > rigbot.travel_dist/2){
        float ideal_dec = rigbot.travel_dist/2 - rigbot.damp_dist;
        //after adjust the dec distance, we can re-calculate the max speed
        rigbot.real_max = sqrt(gacc*2*degree*ideal_dec);
        //then use the desired real max speed to re-calculate all variables
        rigbot.calculateAntiSwing(rigbot.real_max);
    }

    //** main moving part
    if(rigbot.startempty > 10){

        if(rigbot.speed == 0) rigbot.speed = speed_min;

        //jerk acc path
        if(distanceDone < rigbot.jerk_dist){
            //manually update the time frame.
             float t = getDeltaTime(rigbot, distanceDone, rigbot.jerk_dist, rigbot.jerktime);
             rigbot.speed = calculateSpeed(rigbot, t, rigbot.jerktime, true);
             rigbot.lasttime = t;

             if(rigbot.speed>speed_max) rigbot.speed = speed_max;
             if(rigbot.speed<speed_min) rigbot.speed = speed_min;
            //println("JERK:real_traveled:" + (distanceDone) + "need_travel:" + rigbot.jerk_dist + "speed:" + rigbot.speed/2.25);

        }else {
            if(!rigbot.jerk){
                println("JERK_done");
                rigbot.travelTime = 0;
                rigbot.lasttime = 0;
                rigbot.jerk = true;
            }
        }

        //constant acc path
        if(rigbot.jerk && !rigbot.cons){

            float dis_acc = abs(distanceDone - rigbot.jerk_dist);

            //if the distance result is bigger than half of the travel distance, we need to make it as half of the total distance. if do so, we need to re-calculate the rest variables when we complete this part
            if(rigbot.acc_dist + rigbot.jerk_dist > rigbot.travel_dist/2){
                rigbot.acc_dist = rigbot.travel_dist/2 - rigbot.jerk_dist;
            }

            if(dis_acc < rigbot.acc_dist){
                float t = getDeltaTime(rigbot, dis_acc, rigbot.acc_dist, rigbot.acc_t);
                t = map(t, 0, rigbot.acc_t, speed_min/(rigbot.real_max), 1);
                rigbot.speed = min(rigbot.real_max * t, rigbot.real_max);
                rigbot.lasttime = rigbot.travelTime;

                //leave constant speed period to dec part
                if(rigbot.speed == rigbot.real_max){
                    finishAcc(rigbot, dis_acc);
                }
                //println("ACC:real_traveled:" + (dis_acc *mmToToio) + "need_travel:" + rigbot.acc_dist + "speed:" + rigbot.speed/2.25);
            }else {
                finishAcc(rigbot, dis_acc);
            }
        }

        //damp acc path
        if(rigbot.cons && !rigbot.damp){
            float dist_damp = distanceDone - rigbot.dist_done;
            //println("dist_damp" + dist_damp + "damp:" +rigbot.damp_dist);

            if(dist_damp < rigbot.damp_dist){

                float t = getDeltaTime(rigbot, dist_damp, rigbot.damp_dist, rigbot.jerktime);
                rigbot.speed = calculateSpeed(rigbot, t, rigbot.jerktime, false);
                rigbot.lasttime = t;

                if(rigbot.speed>rigbot.real_max) rigbot.speed = rigbot.real_max;
                if(rigbot.speed<speed_min) rigbot.speed = speed_min;
                //println("DAMP:real_traveled:" + (dist_damp ) + "need_travel:" + rigbot.damp_dist + "speed:" + rigbot.speed/2.25);

            } else {
                println("Damp_done");
                rigbot.travelTime = 0;
                rigbot.lasttime = 0;
                rigbot.damp = true;
            }
        }
        //dec path
        if(rigbot.damp ){
            float dis_dec = rigbot.dec_dist - (distanceRemain - 10/mmToToio);
            //println("remian" + cubes[id].distance(tx, ty));
            if(dis_dec <= rigbot.dec_dist){

                float tt = map(dis_dec, 0, rigbot.dec_dist, 0, rigbot.dec_t);
                //float t_max = 1;
                float t_max = 1 - (10*2.25)/rigbot.real_max;
                float t = map(tt, 0, rigbot.dec_t, 0, t_max);

                //println("dec_t" +rigbot.acc_t + "tt" + tt + "t" +t);
                rigbot.speed = rigbot.real_max * (1-t);
                rigbot.speed = min(rigbot.speed, rigbot.real_max);
                //println("DEC:real_traveled:" + (dis_dec ) + "need_travel:" + rigbot.dec_dist + "speed:" + rigbot.speed/2.25);
            }
        }
        //return
        if(rigbot.speed < speed_min || distanceRemain <= 10/mmToToio){
            return true;
        }

    } else{
        motorControl(id, 10*a, 10*b, 10);
        rigbot.startempty ++;
        return false;
    }
    motorControl(id, rigbot.speed*a/2.25, rigbot.speed*b/2.25, 10);
    return false;
}






//Helper function to calculate the update time frame
float getDeltaTime(RigBot rigbot, float dist0, float dist, float time){

    float tt = map(dist0, 0, dist, 0, time);
    rigbot.travelTime = max(0,tt);
    float last = rigbot.lasttime;

    if(rigbot.travelTime - last <= 0) rigbot.travelTime = last + time/50;
    return rigbot.travelTime;
}

//Helper function to calculate the speed
float calculateSpeed(RigBot rigbot, float time, float totalTime, boolean up){
    float speed = 0;

    if(up){
        if(time <= totalTime/4){
            speed = 0.5*time*rigbot.acc_j_d(time);
        }else if(totalTime/4< time && time <= totalTime/2){
            speed = 0.5*rigbot.acc_j_d(totalTime/4)*totalTime/2 - 0.5*(totalTime/2-time)*rigbot.acc_j_d(time);
        }else if(totalTime/2< time && time <= 3*totalTime/4){
            speed = 0.5*rigbot.acc_j_d(totalTime/4)*totalTime/2 - 0.5*(time-totalTime/2)*rigbot.acc_j_d(time);
        }else{
            speed = 0.5*(totalTime-time)*rigbot.acc_j_d(totalTime-time);
        }
    } else{
        if(time <= totalTime/4){
            speed = rigbot.real_max - 0.5*time*rigbot.acc_j_d(time);
        }else if(totalTime/4< time && time <= totalTime/2){
            speed = rigbot.real_max - 0.5*rigbot.acc_j_d(totalTime/4)*totalTime/2 - 0.5*(totalTime/2-time)*rigbot.acc_j_d(time);
        }else if(totalTime/2< time && time <= 3*totalTime/4){
            speed = rigbot.real_max - 0.5*rigbot.acc_j_d(totalTime/4)*totalTime/2 - 0.5*(time-totalTime/2)*rigbot.acc_j_d(time);
        }else{
            speed = rigbot.real_max - 0.5*(totalTime-time)*rigbot.acc_j_d(totalTime-time);
        }
    }
    return speed;
}

//Helper function to update the rest variables
void finishAcc(RigBot rigbot, float dis_acc){
    rigbot.travelTime = 0;
    rigbot.lasttime = 0;
    //update the rest values
    rigbot.dist_done = dis_acc + rigbot.jerk_dist;
    rigbot.real_max = rigbot.speed;
    rigbot.calculateAntiSwing(rigbot.real_max);
    rigbot.cons = true;
    println("CAcc_done");
}

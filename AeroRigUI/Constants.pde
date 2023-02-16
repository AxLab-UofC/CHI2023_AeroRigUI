/* -------------------------------------------------------------------------- */
/*              General constants                                             */
/* -------------------------------------------------------------------------- */
///** general constants -- don't change **///
int appFrameRate = 60;
float mmToToio = 0.7238;
float degree = PI / 180;

///** advanced reel mechanism constant **///
// float spinR = 1.92 * degree * mmToToio; //Rreel: 8mm, Rsg: 19.56mm, Rbg:4.7mm delta * (Rs/(Rr*Rb)) = Deg * degree // delta = Deg * Rr*Rb/Rs = 1.92 * degree

///** standard reel mechanism constant **///
float spinR = 10 * degree * mmToToio; //Rreel: 3.5mm, Rsg: 8.89mm, Rbg:19.56mm delta * (Rs/(Rr*Rb)) = Deg * degree // delta = Deg * Rr*Rb/Rs = 7.7 * degree
///** RigBot param **///
float botHeight = 90*mmToToio; // height of RigBot
float botDiameter = 69 * mmToToio; // diameter of the rigging bot

//* toio unit vs. mm
// toio mat Unit => 1260mm = 912, 1188mm = 862
// 420mm = 304, 558mm = 410
// 1:0.7238 | 1.3815:1
// toio width: 31.8mm : 23 | height 26mm : 18.8

///** set up mat data **///
// 1mm:0.7238 | 1.3815mm:1
// int minCoordX = 32;
// int maxCoordX = 646;
// int minCoordY = 32;
// int maxCoordY= 465;
int minCoordX = 32;
int maxCoordX = 883;
int minCoordY = 32;
int maxCoordY= 860;
int matCol = 1;
int matRow = 1;

int MAT_WIDTH = maxCoordX - minCoordX;
int MAT_HEIGHT = maxCoordY - minCoordY;

int total_MAT_WIDTH = MAT_WIDTH * matCol;
int total_MAT_HEIGHT = MAT_HEIGHT * matRow;
int stageWidthMax = 912;
int stageDepthMax = 862;
int stageWidth = MAT_WIDTH; //614
int stageDepth = MAT_HEIGHT; //433
color MainStageColor =  color(200, 230);


/* -------------------------------------------------------------------------- */
/*              STEP 1: How many objects and cubes we have?                   */
/* -------------------------------------------------------------------------- */

// This constant depends on the number of objects you hang
int nObjects = 1;
// define how many toio you use
int nCubes = 6;
// Number of rigBots. Must be at least 1
int nBots = nCubes/2;

/* -------------------------------------------------------------------------- */
/*              STEP 2: set constants for initial CP calculation              */
/* -------------------------------------------------------------------------- */
/*
* distance between connection points in mm
* dist[0] is the distance between connection points 1 and 2,
* dist[1] is the distance between connection points 2 and 3, and so on
*/
int[] dist = {int(160*mmToToio),int(160*mmToToio),int(160*mmToToio),0};
//int[] dist = {int(100 * mmToToio), int(100 * mmToToio), int(100 * mmToToio), 100, 200};



/* -------------------------------------------------------------------------- */
/*              Constants for Payload Check                                   */
/* -------------------------------------------------------------------------- */
float basicPayloadCapacity = 0.94; // basic payload capacity for a single rigbot: 0.94 kg
float accConstant = 3.59; // acceleration constant
float angleConstant = 0.25; // angle constant


/* -------------------------------------------------------------------------- */
/*              Toggle flags and other                                        */
/* -------------------------------------------------------------------------- */
boolean mouseControl = false;//step1: finish mouse control
boolean simControl = true;
boolean calibrateControl = false;

// enable these to render rigBots
boolean combinedMode = true;
boolean enable3Dview = true;
boolean debugView = true;

///* const for simulation *///
//float offset = 0.0; // should be set in calibration, used for testing only
float stringLength = 265; // how long do you want the string to be initially?
float deadZone = 1f; // stop moving toio if within 0.5 of target position
float speed = 200; //sim speed

/* -------------------------------------------------------------------------- */
/*              Constants for speed control                                   */
/* -------------------------------------------------------------------------- */
float g = 9.81; //acceleration of gravity 9.81m/s^2
float gacc = g*1000*mmToToio;  //convert g's unit to toio pixel
float speed_min = 10*2.25;  //min toio move speed (mm/s)
float speed_max = 115*2.25;  //max toio move speed (mm/s)


boolean original_moveto = true;
boolean antisway_moveto = false;

/* -------------------------------------------------------------------------- */
/*                       Your own constants go here                           */
/* -------------------------------------------------------------------------- */


float max_user_speed = 70; //default max speed of toio


/* -------------------------------------------------------------------------- */
/*                         Safety Check functions                             */
/* -------------------------------------------------------------------------- */

void safetyCheck(){
  objWeight = float(objectWeightTextField.getText());
  numOfRigBotsSelected = int(numberOfRigBOtsTextField.getText());
  if ((objWeight != objWeight) || (numOfRigBotsSelected != numOfRigBotsSelected)) {
    cautionText.setText("invalid input");
    cautionText.setColorValue(color(255, 0, 0));
    maxAccel.setText("Max acceleration: " + 0 + " m/s^2");
    maxAngle.setText("Max angle: " + 0 + " degrees");
  } else {
    boolean capCheck = payloadCapacityCheck(objWeight, numOfRigBotsSelected);
    float p = payload(objWeight);
    float pc = payloadCapacity(numOfRigBotsSelected);
    float cautionThreshold = 6.47 * numOfRigBotsSelected;
    if (capCheck && p <= cautionThreshold) {
      cautionText.setText("SAFE: object within payload capacity");
      cautionText.setColorValue(color(0, 255, 0));
      maxAccel.setText("Max acceleration: " + maxAcceleration(p, pc) + " m/s^2");
      maxAngle.setText("Max angle: " + maxAngle(p, pc) + " degrees");
      accelControl.setRange(0, maxAcceleration(p, pc));
    } else if (capCheck && p > cautionThreshold) {
      cautionText.setText("CAUTION: heavy object");
      cautionText.setColorValue(color(255, 255, 0));
      maxAccel.setText("Max acceleration: " + maxAcceleration(p, pc) + " m/s^2");
      maxAngle.setText("Max angle: " + maxAngle(p, pc) + " degrees");
      accelControl.setRange(0, maxAcceleration(p, pc));
    } else {
      cautionText.setText("WARNING: object exceeds payload capacity");
      cautionText.setColorValue(color(255, 0, 0));
      maxAccel.setText("Max acceleration: " + 0 + " m/s^2");
      maxAngle.setText("Max angle: " + 0 + " degrees");
    }
  }
}


// STEP 1: CALCULATE BASIC PAYLOAD AND BASIC PAYLOAD CAPACITY
// payload calculation based on object weight
float payload (float objectWeight) {
  return objectWeight * g;
}

// payload capacity calculation based on number of rigbots
float payloadCapacity (int numRigbots) {
  float m = 5.6167;
  float b = 4.85;
  return m * numRigbots + b;
}

// STEP 2: PAYLOAD CAPACITY CHECK
boolean payloadCapacityCheck (float objectWeight, int numRigbots) {
  return payload(objectWeight) <= payloadCapacity(numRigbots);
}

// STEP 3: CALCULATE MAX ACCELERATION AND MAX ANGLE
// max acceleration calculation based on payload capacity
float maxAcceleration (float payload, float payloadCapacity) {
    return (payloadCapacity - payload) / accConstant;
}

// max angle calculation based on payload capacity
float maxAngle (float payload, float payloadCapacity) {
    return (payloadCapacity - payload) / angleConstant;
}

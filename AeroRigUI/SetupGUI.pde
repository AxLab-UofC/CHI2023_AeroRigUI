/* -------------------------------------------------------------------------- */
/*                                GUI elements                                */
/* -------------------------------------------------------------------------- */

///** GUI controls **///
void setupGUI() {
   cp5 = new ControlP5(this);
   PFont controlFont = createFont("arial", 13);
   PFont groupFont = createFont("arial", 20);
   int groupBarHeight = 30;

   ///** Mode Selection **///
  Group modeSelectionToggles = cp5.addGroup("Mode Selection")
                .setFont(groupFont)
                .setBackgroundColor(color(0, 64))
                .setBarHeight(groupBarHeight)
                .setBackgroundHeight(20);

  simToggle = cp5.addToggle("toggleSim")
     .setLabel("Toggle Sim")
     .setFont(controlFont)
     .setPosition(10, 10)
     .setSize(50, 20)
     .setValue(false)
     .setMode(ControlP5.SWITCH)
     .moveTo(modeSelectionToggles);


   ///** Object Selection **///
   Group objectToggles = cp5.addGroup("Object Selection")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(10);

   cp5.addButton("toggleObject")
      .setLabel("Select Object")
      .setFont(controlFont)
      .setValue(1)
      .setPosition(50, 15)
      .setSize(200,20)
      .moveTo(objectToggles);


   ///** String Length Calibration **///
   Group calibrationToggles = cp5.addGroup("String Length Calibration")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(20);

   cp5.addToggle("buttonCalibrate")
     .setLabel("Calibrate String Length")
     .setFont(controlFont)
     .setValue(true)
     .setPosition(10, 10)
     .setSize(50, 20)
     .moveTo(calibrationToggles)
     .setMode(ControlP5.SWITCH);


  ///** Control Methods **///
  Group controlToggles = cp5.addGroup("Control Method")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(20);

  mouseToggle = cp5.addToggle("toggleDrive")
     .setLabel("Toggle \nMouse \nDrive")
     .setFont(controlFont)
     .setPosition(10, 20)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     .moveTo(controlToggles);

  joystickToggle = cp5.addToggle("toggleJoystick")
     .setLabel("Toggle \nJoystick")
     .setFont(controlFont)
     .setPosition(110, 20)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     .moveTo(controlToggles);

   handToggle = cp5.addToggle("toggleHand")
     .setLabel("Toggle \nHand")
     .setFont(controlFont)
     .setPosition(210, 20)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     .moveTo(controlToggles);


  ///** XYZ-Translation **///
  Group translations = cp5.addGroup("Translation")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(220);

  objectXYControl = cp5.addSlider2D("Object X-Y Control")
                        .setFont(controlFont)
                        .setPosition(3, 20)
                        .setSize(256, 180)
                        .setMinMax(minCoordX, minCoordY, maxCoordX, maxCoordY)
                        .setValue(objects[selectedObject].objectCenter.x, objects[selectedObject].objectCenter.y)
                        .moveTo(translations);


  zControl = cp5.addSlider("Object Z Control")
     .setPosition(310, 20)
     .setSize(30,180)
     .setRange(800, botHeight) //objects[selectedObject].maxZ
     .setValue(objects[selectedObject].objectCenter.z)
     .moveTo(translations);

   // reposition the Label for controller 'slider'
  cp5.getController("Object Z Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.RIGHT_OUTSIDE).setPaddingX(0);
  cp5.getController("Object Z Control").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  ///** Angles **///
  Group rotations = cp5.addGroup("Rotation")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(200);

  yawControl = cp5.addSlider("Object Yaw Control")
     .setFont(controlFont)
     .setPosition(10, 20)
     .setSize(200,20)
     .setRange(-90, 90)
     .setNumberOfTickMarks(17)
     .setValue(objects[selectedObject].yaw)
     .moveTo(rotations);

  pitchControl = cp5.addSlider("Object Pitch Control")
     .setFont(controlFont)
     .setPosition(10, 80)
     .setSize(200,20)
     .setRange(-90, 90)
     .setNumberOfTickMarks(17)
     .setValue(objects[selectedObject].pitch)
     .moveTo(rotations);

  rollControl = cp5.addSlider("Object Roll Control")
     .setFont(controlFont)
     .setPosition(10, 140)
     .setSize(200,20)
     .setRange(-90, 90)
     .setNumberOfTickMarks(17)
     .setValue(objects[selectedObject].roll)
     .moveTo(rotations);


   ///** Stability / Swing **///
  Group swingSlider = cp5.addGroup("Stability / Swing")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(20);

   stringAngleControl = cp5.addSlider("String Angle")
     .setFont(controlFont)
     .setPosition(10, 20)
     .setSize(200,20)
     .setRange(0, 45)
     .setNumberOfTickMarks(18)
     .setValue(objects[selectedObject].stringAngle)
     .moveTo(swingSlider);

  // create a new accordion
  accordion = cp5.addAccordion("acc")
                 .setPosition(1000, 20)
                 .setWidth(350)
                 .addItem(modeSelectionToggles)
                 .setItemHeight(50)
                 .addItem(objectToggles)
                 .setItemHeight(50)
                 .addItem(calibrationToggles)
                 .setItemHeight(50)
                 .addItem(controlToggles)
                 .addItem(translations)
                 .addItem(rotations)
                 .addItem(swingSlider);

  accordion.open(0, 1, 2, 3, 4, 5, 6);

  accordion.setCollapseMode(Accordion.MULTI); //

  cp5.setAutoDraw(false);

  //camera
  cam = new PeasyCam(this, 400);
  cam.setDistance(1000);
  surface.setLocation(100, 100);
}


/* -------------------------------------------------------------------------- */
/*                          PayloadTool elements                              */
/* -------------------------------------------------------------------------- */

///** GUI controls **///
void setupPayloadTool() {

    cpSafety = new ControlP5(this);
    PFont controlFont = createFont("arial", 16);
    PFont groupFont = createFont("arial", 20);
    cpSafety.setFont(controlFont);
    int groupBarHeight = 30;

    ///** Mode Selection **///
    Group payloadSelection = cpSafety.addGroup("Payload Tool")
        .setFont(groupFont)
        .setBackgroundColor(color(0, 64))
        .setBarHeight(groupBarHeight)
        .setBackgroundHeight(20);

    safetyText = cpSafety.addTextlabel("payloadText")
        .setText("Optimize Control For Safety")
        .setFont(groupFont)
        .setPosition(10, 10)
        .setSize(50, 20)
        .moveTo(payloadSelection);

    objectWeightTextField = cpSafety.addTextfield("Object Weight (kg)")
        .setPosition(10, 50)
        .setSize(200, 20)
        .setFont(controlFont)
        .setAutoClear(false)
        .moveTo(payloadSelection);

    numberOfRigBOtsTextField = cpSafety.addTextfield("Number of Rigbots")
        .setPosition(10, 100)
        .setSize(200, 20)
        .setFont(controlFont)
        .setAutoClear(false)
        .moveTo(payloadSelection);

    cautionText = cpSafety.addTextlabel("cautionText")
        .setText("Caution: object too heavy")
        .setColorValue(color(255, 255, 0))
        .setFont(groupFont)
        .setPosition(10, 150)
        .setSize(50, 20)
        .moveTo(payloadSelection);

    divider = cpSafety.addBang("")
        .setPosition(10, 180)
        .setSize(300, 1)
        .setColorValue(color(255, 255, 255))
        .moveTo(payloadSelection);

    maxAccel = cpSafety.addTextlabel("maxAccel")
        .setText("Max Acceleration: 0.0 m/s^2")
        .setFont(groupFont)
        .setPosition(10, 200)
        .setSize(50, 20)
        .moveTo(payloadSelection);

    maxAngle = cpSafety.addTextlabel("maxAngle")
        .setText("Max Angle: 0.0 degrees")
        .setFont(groupFont)
        .setPosition(10, 230)
        .setSize(50, 20)
        .moveTo(payloadSelection);


  ///** Angles **///
  Group rigbotMovementGroup = cpSafety.addGroup("Rigbot Movement")
                .setFont(groupFont)
                .setBarHeight(groupBarHeight)
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(200);


    controlRadio = cpSafety.addRadio("controlRadio")
        .setPosition(10, 20)
        .setSize(30, 20)
        .setFont(groupFont)
        .setItemsPerRow(2)
        .setSpacingColumn(100)
        .addItem("ease-out", 0)
        .addItem("anti-swing", 1)
        .addItem("ease-in & ease-out", 2)
        .activate(1)
        .moveTo(rigbotMovementGroup);

  accelControl = cpSafety.addSlider("Acceleration")
     .setFont(controlFont)
     .setPosition(10, 80)
     .setSize(200,20)
     .setRange(0, 100)
     .setNumberOfTickMarks(0)
     .setValue(25)
     .moveTo(rigbotMovementGroup);



    // maxAccelBar = cpSafety.addSpacer("weqweqweqwe")
    //     .setPosition(150, 70)
    //     .setSize(100, 100)
    //     .setColor(color(255,0,0))
    //     .moveTo(rigbotMovementGroup);

  // create a new accordion
  accordionLeft = cpSafety.addAccordion("acc")
                 .setPosition(20, 500)
                 .setWidth(350)
                 .addItem(payloadSelection)
                 .setItemHeight(280)
                 .addItem(rigbotMovementGroup);



  accordionLeft.open(0, 1);

  accordionLeft.setCollapseMode(Accordion.MULTI); //

  cpSafety.setAutoDraw(false);
}

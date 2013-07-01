import processing.serial.*;
import intel.pcsdk.*;

PXCUPipeline session;
PImage rgbTex;

int[] faceLabels = {PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_OUTER_CORNER,
                  PXCMFaceAnalysis.Landmark.LABEL_LEFT_EYE_INNER_CORNER,
                  PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_OUTER_CORNER,
                  PXCMFaceAnalysis.Landmark.LABEL_RIGHT_EYE_INNER_CORNER,
                  PXCMFaceAnalysis.Landmark.LABEL_MOUTH_LEFT_CORNER,
                  PXCMFaceAnalysis.Landmark.LABEL_MOUTH_RIGHT_CORNER};

ArrayList<PXCMPoint3DF32> facePts = new ArrayList<PXCMPoint3DF32>();
ArrayList<PXCMRectU32> faceBoxes = new ArrayList<PXCMRectU32>();

Serial stepper, panTilt;

char movement = 100;
boolean useGesture = false;
boolean useStepper = true;

int panAmt = 0;
int tiltAmt = 0;
int panDest = 0;
int tiltDest = 0;
int faceDelay = 6;
int bFoundFace = 0;
int currFaceX, currFaceY;
int closeDelay = 10;
int bTooClose = 0;
boolean bStepperWaiting = false;

String[] commands = {"hello", "what's up", "hello bitch", "hey", "hi", "good morning", "good night", "good evening",
"ok", "good", "all right", 
"bad", "not too good", "not good",
"how are you", "bye", "good bye"};
int voiceIndex = 1;

void setup()
{
  size(640,480);
  println(Serial.list());
  stepper = new Serial(this, Serial.list()[1], 9600);
  panTilt = new Serial(this, Serial.list()[0], 9600);
  rgbTex = createImage(640,480,RGB);
  session = new PXCUPipeline(this);
  //PXCUPipeline.COLOR_VGA|PXCUPipeline.FACE_LOCATION|PXCUPipeline.FACE_LANDMARK
  session.Init(PXCUPipeline.FACE_LOCATION|PXCUPipeline.VOICE_RECOGNITION|(useGesture ? PXCUPipeline.GESTURE : 0));  
  session.SetVoiceCommands(commands);
}

void draw()
{
  if(session.AcquireFrame(false))
  {
    //session.QueryRGB(rgbTex);
    facePts.clear();
    faceBoxes.clear();
    
    //get all face data
    for(int i=0;;++i)
    {
      long[] ft = new long[2];
      if(!session.QueryFaceID(i,ft))
        break;
      PXCMFaceAnalysis.Detection.Data fdata = new PXCMFaceAnalysis.Detection.Data();
      if(session.QueryFaceLocationData((int)ft[0], fdata))
      {
        faceBoxes.add(fdata.rectangle);
        
        PXCMFaceAnalysis.Landmark.LandmarkData lmark = new PXCMFaceAnalysis.Landmark.LandmarkData();
        for(int f=0;f<faceLabels.length;++f)
        { 
          if(session.QueryFaceLandmarkData((int)ft[0],faceLabels[f], 0, lmark))
          {
            facePts.add(lmark.position);
          }
        }
      }
    }
    
    //query for voice commands
    PXCMVoiceRecognition.Recognition recoData = new PXCMVoiceRecognition.Recognition();
    if(session.QueryVoiceRecognized(recoData)){
      String voice = recoData.dictation; 
      println(voice);
      if (voice.equals("hello") || voice.equals("hi") || voice.equals("hey") || voice.equals("what's up") || voice.equals("hello bitch") || voice.equals("good morning") || voice.equals("good night") || voice.equals("good evening")){
        voiceIndex = 2;
      } else if (voice.equals("ok") || voice.equals("good") || voice.equals("all right")){
        voiceIndex = 4;
      } else if (voice.equals("bad") || voice.equals("not too good") || voice.equals("not good")){
        voiceIndex = 3;
      } else if (voice.equals("how are you")){
        voiceIndex = 5;
      } else if (voice.equals("bye") || voice.equals("good bye")){
        voiceIndex = 6;
      }
    }
    
    if (useGesture){
      //get hand data
      bTooClose = constrain(bTooClose - 1, 0, closeDelay);
      PXCMGesture.GeoNode h = new PXCMGesture.GeoNode();
      if (session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY, h)){
        if (h.positionWorld.z > -.05){
          bTooClose = closeDelay;
        }
      }
      if (voiceIndex != 8 && session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_SECONDARY, h)){
        if (h.positionWorld.z > -.05){
          bTooClose = closeDelay;
        }
      }
      if (bTooClose == 0 && voiceIndex == 8){
        voiceIndex = 1;
      } else if (bTooClose > 0){
        voiceIndex = 8;
      }
    }
    
    session.ReleaseFrame();
  }
  //image(rgbTex,0,0);
  pushStyle();
  stroke(255);
  noFill();
  for(int f=0;f<faceBoxes.size();++f)
  {
    PXCMRectU32 faceLoc = (PXCMRectU32)faceBoxes.get(f);
    movement = (char)constrain(faceLoc.y, 0, 255);
    stroke(255, movement > 100 ? 0 : 255, 0);
    rect(faceLoc.x,faceLoc.y,faceLoc.w,faceLoc.h);
    if (f == 0){
      bFoundFace = faceDelay;
      currFaceX = faceLoc.x + faceLoc.w/2 - width/2;
      currFaceY = faceLoc.y + faceLoc.h/2 - height/2;
    }
  }
  fill(0,255,0);
  for(int g=0;g<facePts.size();++g)
  {
    PXCMPoint3DF32 facePt = (PXCMPoint3DF32)facePts.get(g);
    ellipse(facePt.x,facePt.y,5,5);
  }  
  popStyle();
}

void serialEvent(Serial port){
  if (port == stepper){
    bStepperWaiting = true;
    port.clear();
  } else if (port == panTilt){
    int got = port.read();
    port.clear();
    if (bFoundFace == 0 && bTooClose == 0){
      if (panAmt == panDest && tiltAmt == tiltDest){
        panDest = (int)random(-70, 70);
        tiltDest = (int)random(-30, 30);
        println("got to dest! new dest: " + panDest + ":" + tiltDest);
      }
      int panDiff = panDest - panAmt;
      panAmt += constrain(panDiff, -2, 2);
      int tiltDiff = tiltDest - tiltAmt;
      tiltAmt += constrain(tiltDiff, -2, 2);
      voiceIndex = 1;
    } else if (bFoundFace > 0) {
        //NOTE: lower tilt values = tilt forward
        // lower pan values = pan to its left
      panAmt += map(currFaceX, -width/2, width/2, -7, 7);
      tiltAmt += map(currFaceY, -height/2, height/2, 7, -7);
    }
    panAmt = constrain(panAmt, -90, 90);
    tiltAmt = constrain(tiltAmt, -90, 90);
    port.write(panAmt);
    port.write(tiltAmt);
    port.write(bFoundFace > 0 ? voiceIndex : 0);
    bFoundFace = constrain(bFoundFace - 1, 0, faceDelay);
  }
  if (bStepperWaiting && bFoundFace > 0 && tiltAmt != 0 && useStepper){
    stepper.write(tiltAmt > 0 ? 99 : 101);//tilt > 0 means we want to move up
    bStepperWaiting = false;
  }
}

//void keyPressed(){
//  panTilt.write(0);
//  panTilt.write(5);
//}

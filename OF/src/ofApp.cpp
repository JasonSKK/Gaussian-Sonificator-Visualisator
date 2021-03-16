#include "ofApp.h"

//Inspired by Lewis Lepton's example: Rectangle loop

//--------------------------------------------------------------
void ofApp::setup(){
    cam.setDistance(250);

    ofBackground(200);
    osc.setup(PORT);
    //float initialval = 127;
    oscx = 0.0;

}

//--------------------------------------------------------------
void ofApp::update(){
    while(osc.hasWaitingMessages()) {
        ofxOscMessage m;
        osc.getNextMessage(&m);

        if(m.getAddress() == "/gauss-value") {
            oscx = m.getArgAsFloat(0);
            counter++;

        }

    }
}

//--------------------------------------------------------------
void ofApp::draw(){

    ofTranslate(ofGetWidth() / 2 , ofGetHeight() /2);
    ofNoFill();
    ofSetLineWidth(0.1);
    ofSetRectMode(OF_RECTMODE_CENTER);

    //  while(initialval != oscx){
    // initialval = initialval + 1;
    //  sleep(0.1);
    //}

    for(int i = 0; i < 900; i++){

        if(initialval < oscx){
            initialval = initialval + 0.00125;
            blue = initialval * 4 - 0.00225;
            red = initialval * 2 + 0.00225;
            sleep(0.01);
        };

        if(initialval > oscx){
            initialval = initialval - 0.00125;

           blue = initialval * 4 + 0.00225;
            red = initialval * 2 - 0.00225;
            sleep(0.01);
        };



        if(xcor < oscx && counter % 2 == 0){
            if(xcor >= oscx - 100){
                step = step/10;
            };
          xcor = xcor + step;
          sleep(0.1);
          };

        if(xcor > oscx && counter % 2 == 0){
            if(xcor <= oscx + 100){
                step = step/10;
            };
          xcor = xcor - step;
          sleep(0.1);
          };

        if(ycor < oscx && counter % 2 == 0){
            if(ycor >= oscx - 100){
                step = step/10;
            };
          ycor = ycor + step;
          sleep(0.1);
          };


        if(ycor > oscx  && counter % 2 == 0){
            if(xcor <= oscx - 100){
                step = step/10;
            };
          ycor = ycor + step;
          sleep(0.5);
          };




        ofDrawBitmapString(counter, 450, 150);
        //sleep(0.2);



        //what to do
        //gotta have R G B.
        //if value < 30 then more blue
        //if(oscx < 1) {initialval = 1;}

        //if(oscx < 200 && oscx > 10){

            //            while(red < oscx){red = red + 1;}
            //            while(red > oscx){red = red - 1;}

            //for test
            //red = 255;
        //};




    }

    //initialval = ofClamp(initialval, 0.0, 200);
    cam.begin();


    //


    for (int i = 0; i < 100; i++) {
        ofSetColor(red * sin( cos(initialval * 0.01) * i * 0.02) + (sin(i * 0.01)),
                   ofNoise(initialval * 2) * ofRandom(5.0, 10.0),
                   sin(i * 0.01) * blue - (blue/2 * 0.5));//* 0.822);
         ofRotateDeg(ofGetElapsedTimef() + (initialval * 0.1));//* -1 for backwards
        ofScale(0.88);
        //ofDrawCone(0, 0, 500, 500);////////////////////UNCOMMENT HERE
        ofDrawCone(ofClamp(xcor, 50.0, 200.0),//100 200
                   ofClamp(ycor, 50.0, 200.0),
                   200, 200);//,
                   //initialval);
    }

    cam.end();

}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){

}

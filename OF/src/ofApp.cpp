#include "ofApp.h"

//Inspired by Lewis Lepton's example: Rectangle loop

//--------------------------------------------------------------
void ofApp::setup(){
    cam.setDistance(250);

    ofBackground(200);
    osc.setup(PORT);
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

    for(int i = 0; i < 900; i++){

        if(initialval < oscx){
            initialval = initialval + 0.00125;
            blue = initialval - 0.00225;
            red = initialval + 0.00225;
            sleep(0.001);
        };

        if(initialval > oscx){
            initialval = initialval - 0.00125;

           blue = initialval + 0.00225;
            red = initialval - 0.00225;
            sleep(0.001);
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

    }



    cam.begin();

    for (int i = 0; i < 100; i++) {
        ofSetColor(red * sin( cos(initialval * 0.01) * i * 0.02) + (sin(i * 0.01)),
                   ofNoise(initialval) * ofRandom(5.0, 10.0),
                   sin(i * 0.01) * blue - (blue/2 * 0.5));
        ofRotateDeg(ofGetElapsedTimef() + (initialval * 0.02)); //* -1 for backwards
        ofScale(0.88);

        ofDrawCone(ofClamp(xcor, 50.0, 200.0),
                   ofClamp(ycor, 50.0, 200.0),
                   200, 200);
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

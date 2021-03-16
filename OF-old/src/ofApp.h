#pragma once

#include "ofMain.h"
#include "ofxOsc.h"

#define PORT 12345

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

    ofEasyCam cam;

    ofxOscReceiver osc;
    float oscx = 0.0;
    float xcor = 0.0;
    float ycor = 0.0;

    float initialval = 0;
    int counter = 0;
    float step = 0.01;

    float red = 0;
    float green = 0;
    float blue = 0;



};

#include "ofMain.h"
#include "testApp.h"
#include "ofxiPhoneExtras.h"

int main(){	
	ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
	
	//iOSWindow->enableDepthBuffer();
	//iOSWindow->enableAntiAliasing(4);
	
	iOSWindow->enableDepthBuffer();
	iOSWindow->enableRetinaSupport();
	
	ofSetupOpenGL(iOSWindow, 1024,768, OF_FULLSCREEN);			// <-------- setup the GL context
	ofRunApp(new testApp);
}
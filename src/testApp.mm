#include "testApp.h"
#include "bludPd.h"
#include "bludAnalytics.h"
#include <curl/curl.h>
#include "Lua-cURL.h"

//--------------------------------------------------------------
void testApp::setup(){
        
    int startTime = ofGetElapsedTimeMillis();
    cout << "start time: " << startTime << endl;
    ofRegisterTouchEvents(this);
    ofxiPhoneAlerts.addListener(this);  

    ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_PORTRAIT);
    int ticksPerBuffer = 4;	// 8 * 64 = buffer len of 1024
    
	pd = bludPdInstance::getInstance();
	if(!pd->init(2, 0, 22050, ticksPerBuffer)) {
		ofLog(OF_LOG_ERROR, "Could not init pd");
		OF_EXIT_APP(1);
	}
	pd->dspOn();
	Patch patch = pd->openPatch("lipt_/pd_audio/main_audio.pd");
    
	cout << patch << endl;
    cout << "loaded pd: " << ofGetElapsedTimeMillis() - startTime << endl;

    cout << "loaded soundstream: " << ofGetElapsedTimeMillis() - startTime << endl;

    
    blud.setup();
    
    // setup the physicsfs first so that lua has access to it
    PHYSFS_init(NULL);
    
    // bring all the zip files in the documents directory into physfs
    ofDirectory dir;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"/"];
    dir.allowExt("zip");
    dir.listDir([filePath UTF8String]);
    vector<ofFile> files = dir.getFiles();
    for(int i = 0; i < (int)files.size(); i++) {
        cout << "zip in documents: " << files[i].getAbsolutePath().c_str() << endl;
        int e = PHYSFS_mount(files[i].getAbsolutePath().c_str(),"", 1);
        if(e==0){
            cout << "error mounting: " << PHYSFS_getLastError() << endl;
        }
    }
    // bring in the default samplelib
    int e = PHYSFS_mount(ofToDataPath("sampleLib.zip").c_str(),"", 1);
    if(e==0){
        cout << "error mounting: " << PHYSFS_getLastError() << endl;
    }
    cout << "does note6 exist: " << PHYSFS_exists("note6.wav") << endl;

    // need to load the core file after pd so that the seed is loaded in properly for the first world
    
	Lunar<bludPd>::Register(blud.luaVM);
	Lunar<bludGK>::Register(blud.luaVM);
    Lunar<bludAnalytics>::Register(blud.luaVM);
    Lunar<PFileSystem>::Register(blud.luaVM);
    
    Lunar<SampleData>::Register(blud.luaVM);
    Lunar<ChainModel>::Register(blud.luaVM);
    Lunar<PhraseModel>::Register(blud.luaVM);
    Lunar<InstrumentModel>::Register(blud.luaVM);
    Lunar<SongModel>::Register(blud.luaVM);
    Lunar<tPlayer>::Register(blud.luaVM);
    
    luaopen_cURL(blud.luaVM);
	cout << blud.executeFile("lipt_/core.lua") << endl; // this returns an error code for the compiled code
    cout << "loaded blud: " << ofGetElapsedTimeMillis() - startTime << endl;
    player = Player::getInstance();
	mixer = bludMixer::getInstance();
    ofSoundStreamSetup(2,0,this, 44100, ofxPd::getBlockSize()*ticksPerBuffer, 4);
}

//--------------------------------------------------------------
void testApp::update(){
}

//--------------------------------------------------------------
void testApp::draw(){
//    test.draw(0,0);
}
void testApp::audioRequested(float * output, int bufferSize, int nChannels){
    for(int i = 0; i < bufferSize; i++) {
		output[i*2] = 0;
		output[i*2+1] = 0;
	}
    //pd->audioOut(output, bufferSize, nChannels);
    player->audioRequested(output, bufferSize, nChannels);
    mixer->audioRequested(output, bufferSize, nChannels);
}

//--------------------------------------------------------------
void testApp::exit(){
	
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
	
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args){
	
}

//--------------------------------------------------------------
void testApp::lostFocus(){
	
}
	
//--------------------------------------------------------------
void testApp::gotFocus(){
	// call into blud to let it know that we just came back from sleep
    blud.execute("blud.gotFocus()");
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
	
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    // check to see if we are on an ipad, and if so, support switching to the upsidedown and rightside up orientations
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(newOrientation == OF_ORIENTATION_DEFAULT || newOrientation == OF_ORIENTATION_180){
            ofxiPhoneSetOrientation((ofOrientation)newOrientation);
        }
    }
	cout << "orientation changed: " << newOrientation << endl;
}


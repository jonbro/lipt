#include "liptMixer.h"

ofSoundMixer* liptMixer::instance = NULL; 
ofxSynthWaveWriter* liptMixer::writer = NULL; 

ofSoundMixer* liptMixer::getInstance(){
	if (!instance){
        instance = new ofSoundMixer();
        writer = new ofxSynthWaveWriter();
        writer->addInputFrom(instance);
    }   // Only allow one instance of class to be generated.
    
	return instance;	
}
ofSoundSource* liptMixer::getOutput(){
    if(!instance){
        liptMixer::getInstance();
    }
    return writer;
}
void liptMixer::startRecording(string filename){
    if(instance){
        writer->startWriting(filename);
    }
}
void liptMixer::stopRecording(){
    if(instance){
        writer->stopWriting();
    }    
}

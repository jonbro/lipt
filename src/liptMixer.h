#pragma once

#include "ofSoundUnit.h"
#include "ofxSynthWaveWriter.h"
/**
 * mixes the outputs of multiple synths
 * 
 * supports recording the mixed output
 * 
 * a singleton wrapper for the ofSoundMixer
 * Uses a singleton pattern
 */

class liptMixer{
public:
    static ofSoundMixer* getInstance();
    static ofSoundSource* getOutput();
    static void startRecording(string filename = "out.wav");
    static void stopRecording();
    
private:
    static ofSoundMixer *instance;
    static ofxSynthWaveWriter *writer;
};
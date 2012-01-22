#pragma once

#include "SongModel.h"
#include "ofxSynth.h"
#include "liptSampler.h"
#include "liptMixer.h"
#include "WavFile.h"

#define NUM_CHANNELS 8

class Player : public ofSoundSource{
public:
    virtual string	getName() { return "Player"; }
    void	setup();
    static	Player* getInstance();
    
    void    moveToNextStep();
    void    moveToNextPhrase(int channel,int hop=-1);
    void    moveToNextChain(int channel,int hop=-1);
    
    void    previewSample(ofxSynthSample &sample);
    
    void    tick();
    void    startAll(int step);
    void    startChan(int chan, int step);
    void    setSong(SongModel *s);
    void    setTempo(int tempo);
    int     getTickSampleCount();
    void	audioRequested( float* buffer, int numFrames, int numChannels );
    void	setSampleRate(int rate);
    void    render(string output);
    
private:
    // singleton
    Player();
    static Player *instance;
    SongModel *song;
    
    bool playing[NUM_CHANNELS];
    bool hasSong;
    liptSampler channels[NUM_CHANNELS]; // the synthesizers
    ofSoundMixer *mixer;
    
    liptSampler preview;
    ofxSynthSample *previewSampleData;
    bool        hasPreviewSample;
    
    int songStep[NUM_CHANNELS]; // where in the song each channel is
    int currentChain[NUM_CHANNELS]; // the currently playing chain for each channel... incase things get deleted while playing
    int chainStep[NUM_CHANNELS]; // where in the chain each channel is
    int currentPhrase[NUM_CHANNELS]; // the currently playing phrase in the channel
    int phraseStep[NUM_CHANNELS]; // where in the phrase the channel is
    
    int sampleRate, sampleCount, samplesPerTick;
    
    // for handling rendering
    WavFile *renderOut;
    bool rendering;
    int renderFramesRemaining;
    float *renderData;
    ofxSynthWaveWriter *writer;
};

class tPlayer{
public:
    static const char className[];
	static Lunar<tPlayer>::RegType methods[];  
    tPlayer(lua_State *L){
        p = Player::getInstance();
	};
    int setSong(lua_State *L){
        p->setSong(Lunar<SongModel>::check(L, 1));
        return 1;
    };
    int preview(lua_State *L){
        p->previewSample(Lunar<SampleData>::check(L, 1)->sample);
        return 1;
    }
    int startChan(lua_State *L){
        p->startChan(luaL_checknumber(L, 1), luaL_checknumber(L, 2));
        return 1;
    };
    int setTempo(lua_State *L){
        p->setTempo(luaL_checknumber(L, 1));
        return 1;
    };
    int render(lua_State *L){
        p->render(luaL_checkstring(L, 1));
        return 1;
    }
private:
    Player *p;
};
#pragma once

#include "SongModel.h"
#include "ofxSynth.h"
#include "bludMixer.h"

#define NUM_CHANNELS 8

class Player : public ofSoundSource{
public:
    virtual string	getName() { return "Player"; }
    void	setup();
    static	Player* getInstance();
    
    void    moveToNextStep();
    void    moveToNextPhrase(int channel,int hop=-1);
    void    moveToNextChain(int channel,int hop=-1);
    
    void    tick();
    void    startAll(int step);
    void    startChan(int chan, int step);
    void    setSong(SongModel *s);
    void    setTempo(int tempo);
    
    void		audioRequested( float* buffer, int numFrames, int numChannels );
    void		setSampleRate(int rate);
    
private:
    // singleton
    Player();
    static Player *instance;
    SongModel *song;
    
    bool playing[NUM_CHANNELS];
    bool hasSong;
    ofxSynthSampler channels[NUM_CHANNELS]; // the synthesizers
    ofSoundMixer *mixer;
    
    int songStep[NUM_CHANNELS]; // where in the song each channel is
    int currentChain[NUM_CHANNELS]; // the currently playing chain for each channel... incase things get deleted while playing
    int chainStep[NUM_CHANNELS]; // where in the chain each channel is
    int currentPhrase[NUM_CHANNELS]; // the currently playing phrase in the channel
    int phraseStep[NUM_CHANNELS]; // where in the phrase the channel is
    
    int sampleRate, sampleCount, samplesPerTick;
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
    int startChan(lua_State *L){
        p->startChan(luaL_checknumber(L, 1), luaL_checknumber(L, 2));
        return 1;
    };
    int setTempo(lua_State *L){
        p->setTempo(luaL_checknumber(L, 1));
        return 1;
    };
private:
    Player *p;
};
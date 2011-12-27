#pragma once
#include "lunar.h"
#include "ofxSynthSampler.h"

enum EffectType{
    VOL,
    PTCH
};

typedef struct{
    bool hasEffect;
    EffectType etype;
    int value;
} Effect;

class ChainModel{
public:
	static const char className[];
	static Lunar<ChainModel>::RegType methods[];
	ChainModel(lua_State *L){
        for (int i=0; i<16; i++) {
            hasPhrase[i] = false;
        }        
	}
	ChainModel(){
        for (int i=0; i<16; i++) {
            hasPhrase[i] = false;
        }
	}
    int set(lua_State *L){
        int step = luaL_checkinteger(L, 1);
        hasPhrase[step] = true;
        phrase[step] = luaL_checkinteger(L, 2);
        return 1;
    }
    int clearPhrase(lua_State *L){
        int step = luaL_checkinteger(L, 1);
        hasPhrase[step] = false;
        return 1;
    }

    ~ChainModel(){
	}
    bool hasPhrase[16];
    int phrase[16];
    int transpose[16];
};

class PhraseModel{
public:
	static const char className[];
	static Lunar<PhraseModel>::RegType methods[];
	PhraseModel(lua_State *L){
	}
	PhraseModel(){
        // setup all of the items so that we can access them from lua later
        for (int i=0; i<16; i++) {
            hasNote[i] = false;
            hasInst[i] = false;
            col1[i].hasEffect = false;
            col2[i].hasEffect = false;
        }        
	}
    int set(lua_State *L){
        int step = luaL_checkinteger(L, 1);
        this->hasNote[step] = true;
        this->hasInst[step] = true;
        this->note[step] = luaL_checkinteger(L, 2);
        this->inst[step] = luaL_checkinteger(L, 3);
        return 1;
    }
    int clearNote(lua_State *L){
        int step = luaL_checkinteger(L, 1);
        this->hasNote[step] = false;
        return 1;
    }
    ~PhraseModel(){
	}
    
    bool hasNote[16];
    int note[16];
    bool hasInst[16];
    int inst[16];
    Effect col1[16];
    Effect col2[16];
};

class SampleData{
public:
    static const char className[];
	static Lunar<SampleData>::RegType methods[];
	SampleData(lua_State *L){
	}
    int loadSample(lua_State *L){
        cout << "sample name: " << luaL_checkstring(L, 1) << endl;
        sample.load(luaL_checkstring(L, 1));
        return 1;
    }
    ~SampleData(){
	}
    ofxSynthSample sample;
};

// right now, I don't know what this needs other than a reference to the sample data
// eventually it should probably have the information for the synth to be initialized

class InstrumentModel{
public:
    static const char className[];
	static Lunar<InstrumentModel>::RegType methods[];
	InstrumentModel(lua_State *L){
        hasSample = false;
	}
	InstrumentModel(){
        hasSample = false;
	}
    int setSample(lua_State *L){
        SampleData *s = Lunar<SampleData>::check(L, 1);
        sample = &s->sample;
        hasSample = true;
        return 1;
    }
    ~InstrumentModel(){
	}
    bool hasSample;
    ofxSynthSample *sample;
};

// a list of the chains in each channel
class ChannelModel{
public:
    ChannelModel(){
        for (int i=0; i<128; i++) {
            hasChain[i] = false;
        }        
    };
    bool hasChain[128];
    int chain[128];
};
// contains everything the synth need to play through the song.
// also contains calls that lua can request this data for later editing.
class SongModel{
public:
	static const char className[];
	static Lunar<SongModel>::RegType methods[];
	SongModel(lua_State *L){
        // setup all of the items so that we can access them from lua later
        
	}
    int getInstrument(lua_State *L){
        InstrumentModel *inst = &instrument[luaL_checkinteger(L, 1)];
        Lunar<InstrumentModel>::push(L, inst);
        return 1;
    }
    int clearChain(lua_State *L){
        channel[luaL_checkinteger(L, 1)].hasChain[luaL_checkinteger(L, 2)] = false;
        return 1;
    }
    int setChain(lua_State *L){
        channel[luaL_checkinteger(L, 1)].hasChain[luaL_checkinteger(L, 2)] = true;
        channel[luaL_checkinteger(L, 1)].chain[luaL_checkinteger(L, 2)] = luaL_checkinteger(L, 3);
        return 1;
    }
    int getChain(lua_State *L){
        ChainModel *chain = &this->chain[luaL_checkinteger(L, 1)];
        Lunar<ChainModel>::push(L, chain);
        return 1;
    }
    int getPhrase(lua_State *L){
        PhraseModel *phrase = &this->phrase[luaL_checkinteger(L, 1)];
        
        Lunar<PhraseModel>::push(L, phrase);
        return 1;
    }
    
  
    ~SongModel(){
	}
    int bpm;
    // everything is public so that we can quickly access without function call overhead
    InstrumentModel instrument[256];
    PhraseModel phrase[256];
    ChainModel chain[256];
    ChannelModel channel[8];
};
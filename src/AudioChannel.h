#pragma once
#define NUM_CHANNELS 8
class Player{
public:
    void tick();
    void startAll(int step);
private:
    // singleton
    Player();
    bool playing[NUM_CHANNELS];
    int channels[NUM_CHANNELS]; // the synthesizers
    int songStep[NUM_CHANNELS]; // where in the song each channel is
    int currentChain[NUM_CHANNELS]; // the currently playing chain for each channel... incase things get deleted while playing
    int chainStep[NUM_CHANNELS]; // where in the chain each channel is
    int currentPhrase[NUM_CHANNELS]; // the currently playing phrase in the channel
    int phraseStep[NUM_CHANNELS]; // where in the phrase the channel is
};
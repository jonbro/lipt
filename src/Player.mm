#include "Player.h"

const char tPlayer::className[] = "tPlayer";

Lunar<tPlayer>::RegType tPlayer::methods[] = {
	method(tPlayer,setSong),
	method(tPlayer,startChan),
    method(tPlayer, setTempo),
	{0,0}
};



Player* Player::instance = NULL; 

Player::Player(){
    sampleCount = 0;
    hasSong = false;
    mixer = bludMixer::getInstance();
    for (int i=0; i<NUM_CHANNELS; i++) {
        playing[i] = false;
        // setup the samplers
        mixer->addInputFrom(&channels[i]);
    }
    samplesPerTick = 4000;
    sampleRate = 44100;
}

Player* Player::getInstance(){
	if (!instance){   // Only allow one instance of class to be generated.		
		instance = new Player();
		// connect this input to the mixer so that we can get triggers properly
	}
	return instance;
}

void Player::tick(){
    //    cout << "tick" << endl;
    if(!hasSong)
        return;
    // for each of the channels that are playing, pull out the note / sample that needs to be triggered
    
    for (int i=0; i<NUM_CHANNELS; i++) {
        if(playing[i]){
            PhraseModel *phrase = &song->phrase[currentPhrase[i]];
            if(phrase->hasInst[phraseStep[i]]){
                InstrumentModel inst = song->instrument[phrase->inst[phraseStep[i]]];
                if (inst.hasSample) {
                    channels[i].loadSample(inst.sample);
                    channels[i].setLoopPoints(0, 1);
                    channels[i].setLoopType(inst.loopMode);
                }
            }
            if(phrase->hasNote[phraseStep[i]]){
                // this is where all the data is copied into the sampler
                channels[i].setFrequencyMidiNote(phrase->note[phraseStep[i]]);
                channels[i].trigger();
            }
        }
    }
    moveToNextStep();
}

void Player::moveToNextStep(){
    for (int i=0; i<NUM_CHANNELS; i++) {
        if(playing[i]){
            int step = phraseStep[i]+1;
            if(step != 16){
                // this is where we would do the hop calculation
                phraseStep[i] = step;
            }else{
                moveToNextPhrase(i);
            }
        }
    }
}
void Player::moveToNextPhrase(int channel,int hop){
    // TODO: this is where the checking for queuing in livemode would occur
    
    // instead we are just going to check to see if there is is a phrase in the next position
    ChainModel chain=song->chain[currentChain[channel]];
	int pos=chainStep[channel]+1;
    bool canContinue = (pos < 16);
    if(canContinue){
        canContinue = chain.hasPhrase[pos];
        cout << "has phrase for pos:" << pos << " " << canContinue << endl;
    }
    if(canContinue){
        // if we can still continue, then we need to move the chain forward
        chainStep[channel] = pos;
        // set the new phrase
        currentPhrase[channel] = chain.phrase[pos];
        // set the phrase step back to the beginning    
        phraseStep[channel] = 0;
    }else{
        // if not, we need to move the song forward
        moveToNextChain(channel, hop);
    }
}
void Player::moveToNextChain(int channel,int hop){
    // again, check for queuing. We arn't doing this yet. Some point in the future maybe
  
    
    int pos=songStep[channel]+1 ;
    bool loopBack = !song->channel[channel].hasChain[pos];
    cout << "channel: " << channel << " in pos: " << pos << " has chain: " << (song->channel[channel].hasChain[pos]?"true":"false") << endl;
    if (!loopBack) {
        // if we don't need to loop back, do a double check to make sure that the next chain has a phrase in the first position
        loopBack = !song->chain[song->channel[channel].chain[pos]].hasPhrase[0];
        cout << "found chain in pos: " << pos << "has phrase? " << !loopBack << endl;
    };
    
    // if we still need to loopback
    if (loopBack) {
        // move the position back one
        pos-- ;
        while (pos>=0) {
            bool hasChain = song->channel[channel].hasChain[pos];
            if (!hasChain) { // we stop searching if there's a blank
                break ;
            } else  { // Or if first phrase of chain is empty
                if (!song->chain[song->channel[channel].chain[pos]].hasPhrase[0]) {
                    break ;
                }
            } 
            pos-- ;
        } ;
        pos++ ;
    }
    songStep[channel]=pos;
    // also set the chain and phrase to the first positions
    phraseStep[channel] = 0;
    chainStep[channel] = 0;
    startChan(channel, pos);
}

void Player::setSong(SongModel *s){
    printf("setting song (%p)\n", s);
    song = s;
    hasSong = true;
}

void startAll(int step);

void Player::startChan(int chan, int step){
    // just in case the chan is playing, then stop the chan.
    playing[chan] = false;
    printf("start chan: %i, step: %i on song (%p)\n", chan, step, song);
    // check to see if this step has a valid chain and phrase
    if(song->channel[chan].hasChain[step]){
        ChainModel chain = song->chain[song->channel[chan].chain[step]];
        printf("chain on step: %i is %i, (%p)\n", step, song->channel[chan].chain[step], &chain);
        // check to see if the chain has a phase in the first position
        if(chain.hasPhrase[0]){
            // if everything passed checks, then this channel is playing
            playing[chan] = true;
            songStep[chan] = step;
            currentChain[chan] = song->channel[chan].chain[step];
            chainStep[chan] = 0;
            currentPhrase[chan] = chain.phrase[0];
            phraseStep[chan] = 0;
        }else{
            cout << "chain didn't have phrase" << endl;
        }
    }else{
        cout << "channel didn't have chain" << endl;
    }
    printf("channel 0 playing: %i", playing[0]);
}

void Player::audioRequested( float* buffer, int numFrames, int numChannels ){
    memset(buffer, 0, numFrames*numChannels);
	for (int i = 0; i<numFrames; i++) {
        sampleCount++;
        if(sampleCount%samplesPerTick == 0){
            tick();
        }
	}
}
void Player::setTempo(int tempo){
    // convert the tempo to number of samples
    float clockMult = 4; // because we are doing quarter notes as beats, we need to divide by four
	float bpm = tempo;
	samplesPerTick = (sampleRate*60/bpm)/clockMult;
    
}
void Player::setSampleRate( int rate ){
	sampleRate = rate;
}

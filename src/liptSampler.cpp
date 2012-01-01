#include "liptSampler.h"
#import "Player.h"

void liptSampler::setSampleRate( int rate )
{
	sampleRate = rate;
}
void liptSampler::setLoopPoints(float i, float o){
	inPoint=fmax(0, i);
	outPoint=fmin(1, o);
	inSample = inPoint*sample->length;
	outSample = outPoint*sample->length;
}
void liptSampler::processEffect(EffectType effect, int val1, int val2){
    switch (effect) {
        case VOL:
        {
            float targetVolume = (float)val2/256.0;
            float speed = val1; // this is the distance that we need to move
            speed = (speed==0)?0:fabs(targetVolume-renderParams.volume_)/(Player::getInstance()->getTickSampleCount()*val1);
            renderParams.volumeRamp_.setData(targetVolume, speed, renderParams.volume_);
            if (!renderParams.volumeRamp_.Enabled()) {
                renderParams.volumeRamp_.Enable();
            }
            // trigger once to get rid of th clipping at the beginning
            break;
        }
        case PLOF:
        {
            // jumps to the position in the sample specified
            // should make it respect the loop points, once those are actually implemented
            if(val2==0){
                int targetPosition = (float)val1/256.0*sample->length;
                if(sampleLoaded)
                    position = targetPosition;
            }else{
                int targetPosition = (float)val1/256.0*sample->length;
                if(sampleLoaded)
                    position = (sample->length-targetPosition)%sample->length;
            }
        }
        default:
            break;
    }
}
void liptSampler::trigger(){
    
    // should clear all of the currently running effects
    renderParams.volume_ = 1.0;
    renderParams.volumeRamp_.Disable();
    
    if (sampleLoaded) {
        position = inPoint*sample->length;
        playing = true;
    }
}
void liptSampler::audioRequested( float* buffer, int numFrames, int numChannels ){
    if(!sampleLoaded)
        return;
	sample->setSampleRate(sampleRate);
	// as per the faster processing done in the main synth
	float currValue;
	float *buffer_ptr = buffer;
	for (int i = 0; i < numFrames; i++){
        struct InstrumentParams rup ;
        rup.volumeOffset_=0;
		if(renderParams.volumeRamp_.Enabled()){
            renderParams.volumeRamp_.Trigger(false);
            renderParams.volumeRamp_.UpdateSRP(rup);
            renderParams.volume_ = rup.volumeOffset_;
        }
        if(sampleLoaded && playing){
			play(currentFrequency, inSample, outSample, currValue);
		}else {
			currValue = 0;
		}
        
		for (int j=0; j<numChannels; j++) {
			(*buffer_ptr++) = currValue*renderParams.volume_;
		}
	}

}
void liptSampler::setFrequencyMidiNote(float note){
	currentFrequency = pow(2.0, (note-60.0)/12.0f);
    // this is the sync to loop length calculation
    if(loopType == LOOPSYNC){

        float offset = 16.0 / currentFrequency; // multiplying by 16 because that is the number of ticks per measure currently, and then the octaves double or half the speed
        currentFrequency = sample->length/(Player::getInstance()->getTickSampleCount()*offset); 
//        currentFrequency = currentFrequency*2.0;
    }
}
void liptSampler::setFrequencySyncToLength(int length){
	currentFrequency = sample->length/(float)length;
}
void liptSampler::loadFile(string file){
	bool result = sample->load(ofToDataPath(file));
	sampleLoaded = result;
	printf("sampleload test: %i\n",result);
	printf("Summary:\n%s", sample->getSummary());
	setLoopPoints(0, 1);
}
void liptSampler::loadSample(ofxSynthSample *_sample){
	sampleLoaded = true;
    sample = _sample;
	setLoopPoints(0, 1);
}
void liptSampler::setLoopType(int _loopType){
	loopType = _loopType;
}

//better cubic inerpolation. Cobbled together from various (pd externals, yehar, other places).
double liptSampler::play4(double frequency, double start, double end) {
	double remainder;
	double a,b,c,d,a1,a2,a3;
	short* buffer = (short*)sample->myData;
	if (frequency >0.) {
		if (position<start) {
			position=start;
		}
		if ( position >= end ){
			if (loopType == SINGLE) {
				playing = false;
			}
			position = start;
		}
		position += frequency;
		remainder = position - floor(position);
		if (position>0) {
			a=buffer[(int)(floor(position))-1];
			
		} else {
			a=buffer[0];
		}
		
		b=buffer[(long) position];
		if (position<end-2) {
			c=buffer[(long) position+1];
			
		} else {
			c=buffer[0];
			
		}
		if (position<end-3) {
			d=buffer[(long) position+2];
			
		} else {
			d=buffer[0];
		}
		a1 = 0.5f * (c - a);
		a2 = a - 2.5 * b + 2.f * c - 0.5f * d;
		a3 = 0.5f * (d - a) + 1.5f * (b - c);
		output = (double) (((a3 * remainder + a2) * remainder + a1) * remainder + b) / 32767;
		
	} else {
		frequency=frequency-(frequency+frequency);
		if ( position <= start ) position = end;
		position -= frequency;
		remainder = position - floor(position);
		if (position>start && position < end-1) {
			a=buffer[(long) position+1];
			
		} else {
			a=buffer[0];
			
		}
		
		b=buffer[(long) position];
		if (position>start) {
			c=buffer[(long) position-1];
			
		} else {
			c=buffer[0];
			
		}
		if (position>start+1) {
			d=buffer[(long) position-2];
			
		} else {
			d=buffer[0];
		}
		a1 = 0.5f * (c - a);
		a2 = a - 2.5 * b + 2.f * c - 0.5f * d;
		a3 = 0.5f * (d - a) + 1.5f * (b - c);
		output = (double) (((a3 * remainder + a2) * -remainder + a1) * -remainder + b) / 32767;
		
	}
	
	return(output);
}
void liptSampler::play(float frequency, float start, float end, float &fill) {
    if(!sampleLoaded)
        return;
	double remainder;
	// not sure why I was calculating this every loop, seems unnecessary
	// if (end>=sample.length) end=sample.length-1;
	long a,b;
	short* buffer = (short *)sample->myData;
	if (frequency >0.) {
		if (position<start) {
			position=start;
		}
		
		if ( position >= end ){
			if (loopType == SINGLE) {
				playing = false;
			}
			position = start;
		}
		position += frequency;
		int pos = position; // used to do this with floor, going to try it with a simple cast for speed
		remainder = position - pos;
		if (pos+1<sample->length) {
			a=pos+1;
		}
		else {
			a=pos-1;
		}
		if (pos+2<sample->length) {
			b=pos+2;
		}
		else {
			b=sample->length-1;
		}
//		printf("buffer pos a: %i b: %i", a, b);
		fill = ((1-remainder) * buffer[a] +
						   remainder * buffer[b])/32767.0;//linear interpolation
		// output = ofRandom(-1.0, 1.0);
	} else {
		frequency=frequency-(frequency+frequency);
		if ( position <= start ) position = end;
		position -= frequency;
		remainder = position - floor(position);
		long pos = floor(position);
		if (pos-1>=0) {
			a=pos-1;
		}
		else {
			a=0;
		}
		if (pos-2>=0) {
			b=pos-2;
		}
		else {
			b=0;
		}		
		fill = (double) ((-1-remainder) * buffer[a] +
						   remainder * buffer[b])/32767.0;//linear interpolation
		
	}
	
	//return(output);
}
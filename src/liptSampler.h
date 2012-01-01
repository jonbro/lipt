#pragma once

#include "ofxSynth.h"
#include "ofxSynthSampler.h"
#include "Updaters.h"
#include "SongModel.h"

struct RUParams {
	float volumeOffset_ ;
} ;
enum loopModes{
    SINGLE,
    LOOP,
    LOOPSYNC
};
struct RenderParams{
    VolumeRamp  volumeRamp_;
    float       volume_;    
};

class liptSampler : public ofxSynth {
	public:
		liptSampler()	{
			direction=1; inPoint=0.0;outPoint=1.0;playing=false;
			sampleLoaded=false; currentFrequency=1.0; loopType=SINGLE;
		};
		virtual string		getName() { return "ofxSynthSampler"; }

		void				loadFile(string file);
        void                loadSample(ofxSynthSample *_sample);
    
		void				trigger();
		void				setFrequencyMidiNote(float note);
		void				setFrequencySyncToLength(int length);
        void                processEffect(EffectType effect, int val1, int val2);
		void				setDirectionForward(){direction = 1;};
		void				setDirectionBackward(){direction = -1;};
		void				setLoopPoints(float i, float o);
		void				setLoopType(int _loopType); // 0 loop 1 one shot
	
		void				setSampleRate(int rate);
		virtual void		audioRequested( float* buffer, int numFrames, int numChannels );
		double				play4(double frequency, double start, double end);
		void				play(float frequency, float start, float end, float &fill);

	private:
		int					sampleRate, direction, loopType;
		float				inPoint, outPoint, inSample, outSample;
		ofxSynthSample		*sample;
		bool				sampleLoaded, playing;
        double              position;
		float				output; // used by the playback system
        RenderParams        renderParams;
};
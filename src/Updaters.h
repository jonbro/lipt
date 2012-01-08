#pragma once

// used for updating parameters on the instrument
struct InstrumentParams {
	float volumeOffset_ ;
	float speedOffset_ ;
	float cutOffset_ ;
	float resOffset_ ;
	float panOffset_ ;
};

class Updater {
public:
	Updater() {} ;
	virtual ~Updater() {} ;
	virtual void Trigger(bool tableTick)=0 ;
	virtual void UpdateSRP(struct InstrumentParams &rup)=0 ;
	void Enable() { enabled_=true ;} ;
	void Disable() { enabled_=false ;} ;
	bool Enabled() { return enabled_ ; } ;
protected:
	bool enabled_ ;
} ;

class VolumeRamp : public Updater {
public:
	VolumeRamp() {} ;
    ~VolumeRamp() {} ;
	void setData(float target,float speed,float start);
	virtual void Trigger(bool tableTick) ;
	virtual void UpdateSRP(struct InstrumentParams &rup);
private:
	float current_ ;
	float target_ ;
	float speed_ ;
} ;

class PitchRamp : public Updater {
public:
	PitchRamp() {} ;
    ~PitchRamp() {} ;
	void setData(float target,float speed,float start);
	virtual void Trigger(bool tableTick) ;
	virtual void UpdateSRP(struct InstrumentParams &rup);
private:
	float current_ ;
	float target_ ;
	float speed_ ;
} ;

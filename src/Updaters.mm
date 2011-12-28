#import "Updaters.h"

// the speed is calculated outside, on the instrument
void VolumeRamp::setData(float target,float speed,float start){
    target_ = target;
    speed_ = speed;
    current_ = start;
}

// table tick is only true for updaters that don't get called at samplerate
void VolumeRamp::Trigger(bool tableTick){
    if (!enabled_) return ;
	if (!tableTick) {
		if (speed_==0) {
			current_=target_ ;
		} else {
			if (current_<target_) {
				current_=current_ + speed_;
				if (current_>target_) {
					current_=target_ ;
				}
			} else {
				current_ = current_ - speed_;
				if (current_<target_) {
					current_=target_ ;
				}
			}
		}
	}
}

void VolumeRamp::UpdateSRP(struct InstrumentParams &rup){
    if(!enabled_) return;
    rup.volumeOffset_ = current_;
}
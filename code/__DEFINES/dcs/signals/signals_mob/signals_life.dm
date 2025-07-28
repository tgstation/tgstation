///From living/Life(). (deltatime, times_fired)
#define COMSIG_LIVING_LIFE "living_life"
	/// Block the Life() proc from proceeding... this should really only be done in some really wacky situations.
	#define COMPONENT_LIVING_CANCEL_LIFE_PROCESSING (1<<0)

/// from /mob/living/carbon/Life(): (seconds_per_tick = SSMOBS_DT, times_fired)
#define COMSIG_LIFE_WOUND_PROCESS "life_wound_process"
#define COMSIG_LIFE_WOUND_STASIS_PROCESS "life_wound_stasis_process"
#define COMSIG_LIFE_HANDLE_BODYPARTS "life_handle_bodyparts"

///Sending this signal will return either BLOCK_FIRE bitflag or ALLOW_FIRE bitflag
#define COMSIG_LIVING_FIRING_PIN_CHECK "lasertag_firing_pin_check"
	///blocks the lasertag firing pin from authorizing the shot
	#define BLOCK_FIRE (1 << 0)
	///allows the lasertag firing pin to authorize the shot
	#define ALLOW_FIRE (1 << 1)

///Neutral Lasertag team
#define LASERTAG_TEAM_NEUTRAL "neutral"
///Red Lasertag team
#define LASERTAG_TEAM_RED "red"
///Blue Lasertag team
#define LASERTAG_TEAM_BLUE "blue"

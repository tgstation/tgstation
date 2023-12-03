#define isdarkspawn(A) (A.mind && A.mind.has_antag_datum(/datum/antagonist/darkspawn))
#define isveil(A) (A.mind && A.mind.has_antag_datum(/datum/antagonist/veil))
#define is_darkspawn_or_veil(A) (A.mind && isdarkspawn(A) || isveil(A))

#define DARKSPAWN_DIM_LIGHT 0.2 //light of this intensity suppresses healing and causes very slow burn damage
#define DARKSPAWN_BRIGHT_LIGHT 0.3 //light of this intensity causes rapid burn damage

#define DARKSPAWN_DARK_HEAL 5 //how much damage of each type (with fire damage half rate) is healed in the dark
#define DARKSPAWN_LIGHT_BURN 7 //how much damage the darkspawn receives per tick in lit areas

#define STATUS_EFFECT_CREEP /datum/status_effect/creep //Provides immunity to lightburn for darkspawn, does nothing to anyone else //Massmeta edit
#define STATUS_EFFECT_TIME_DILATION /datum/status_effect/time_dilation //Provides immunity to slowdown and halves click-delay/action times //Massmeta edit
#define STATUS_EFFECT_BROKEN_WILL /datum/status_effect/broken_will //A 30-second sleep effect reduced by 1 second for every point
#define STATUS_EFFECT_TAGALONG /datum/status_effect/tagalong //allows darkspawn to accompany people's shadows

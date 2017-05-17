
//These are all the different status effects. Use the paths for each effect in the defines.

#define STATUS_EFFECT_MULTIPLE 0 //if it allows multiple instances of the effect

#define STATUS_EFFECT_UNIQUE 1 //if it allows only one, preventing new instances

#define STATUS_EFFECT_REPLACE 2 //if it allows only one, but new instances replace

#define BASIC_STATUS_EFFECT /datum/status_effect //Has no effect.

///////////
// BUFFS //
///////////

#define STATUS_EFFECT_SHADOW_MEND /datum/status_effect/shadow_mend //Quick, powerful heal that deals damage afterwards. Heals 15 brute/burn every second for 3 seconds.
#define STATUS_EFFECT_VOID_PRICE /datum/status_effect/void_price //The price of healing yourself with void energy. Deals 3 brute damage every 3 seconds for 30 seconds.

#define STATUS_EFFECT_VANGUARD /datum/status_effect/vanguard_shield //Grants temporary stun absorption, but will stun the user based on how many stuns they absorbed.
#define STATUS_EFFECT_INATHNEQS_ENDOWMENT /datum/status_effect/inathneqs_endowment //A 15-second invulnerability and stun absorption, granted by Inath-neq.
#define STATUS_EFFECT_WRAITHSPECS /datum/status_effect/wraith_spectacles

#define STATUS_EFFECT_POWERREGEN /datum/status_effect/cyborg_power_regen //Regenerates power on a given cyborg over time

#define STATUS_EFFECT_HISGRACE /datum/status_effect/his_grace //His Grace.

#define STATUS_EFFECT_WISH_GRANTERS_GIFT /datum/status_effect/wish_granters_gift //If you're currently resurrecting with the Wish Granter

/////////////
// DEBUFFS //
/////////////

#define STATUS_EFFECT_SIGILMARK /datum/status_effect/sigil_mark
#define STATUS_EFFECT_BELLIGERENT /datum/status_effect/belligerent //forces the affected to walk, doing damage if they try to run

#define STATUS_EFFECT_MANIAMOTOR /datum/status_effect/maniamotor //disrupts, damages, and confuses the affected as long as they're in range of the motor
#define MAX_MANIA_SEVERITY 100 //how high the mania severity can go
#define MANIA_DAMAGE_TO_CONVERT 90 //how much damage is required before it'll convert affected targets

#define STATUS_EFFECT_HISWRATH /datum/status_effect/his_wrath //His Wrath.

#define STATUS_EFFECT_SUMMONEDGHOST /datum/status_effect/cultghost //is a cult ghost and can't use manifest runes

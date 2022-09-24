#define NITRILE_GLOVES_MULTIPLIER 0.5
///multiplies the time of do_mob by NITRILE_GLOVES_MULTIPLIER if the user has the TRAIT_FAST_MED
#define CHEM_INTERACT_DELAY(delay, user) HAS_TRAIT(user, TRAIT_FAST_MED) ? (delay * NITRILE_GLOVES_MULTIPLIER) : delay

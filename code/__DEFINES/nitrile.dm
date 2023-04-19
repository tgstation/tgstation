#define NITRILE_GLOVES_MULTIPLIER 0.5
///multiplies the time of do_after by NITRILE_GLOVES_MULTIPLIER if the user has the TRAIT_FASTMED
#define CHEM_INTERACT_DELAY(delay, user) HAS_TRAIT(user, TRAIT_FASTMED) ? (delay * NITRILE_GLOVES_MULTIPLIER) : delay

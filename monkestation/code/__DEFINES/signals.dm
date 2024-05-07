/// Sent from [/mob/living/examine] late, after the first signal is sent, but BEFORE flavor text handling,
/// for when you prefer something guaranteed to appear at the bottom of the stack
/// (Flavor text should stay at the very very bottom though)
#define COMSIG_LIVING_LATE_EXAMINE "late_examine"

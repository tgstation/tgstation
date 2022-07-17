///if it allows multiple instances of the effect
#define STATUS_EFFECT_MULTIPLE 0
///if it allows only one, preventing new instances
#define STATUS_EFFECT_UNIQUE 1
///if it allows only one, but new instances replace
#define STATUS_EFFECT_REPLACE 2
/// if it only allows one, and new instances just instead refresh the timer
#define STATUS_EFFECT_REFRESH 3

///Processing flags - used to define the speed at which the status will work
///This is fast - 0.2s between ticks (I believe!)
#define STATUS_EFFECT_FAST_PROCESS 0
///This is slower and better for more intensive status effects - 1s between ticks
#define STATUS_EFFECT_NORMAL_PROCESS 1

//several flags for the Necropolis curse status effect
///makes the edges of the target's screen obscured
#define CURSE_BLINDING (1<<0)
///spawns creatures that attack the target only
#define CURSE_SPAWNING (1<<1)
///causes gradual damage
#define CURSE_WASTING (1<<2)
///hands reach out from the sides of the screen, doing damage and stunning if they hit the target
#define CURSE_GRASPING (1<<3)

//Incapacitated status effect flags
/// If the incapacitated status effect will ignore a mob in restraints (handcuffs)
#define IGNORE_RESTRAINTS (1<<0)
/// If the incapacitated status effect will ignore a mob in stasis (stasis beds)
#define IGNORE_STASIS (1<<1)
/// If the incapacitated status effect will ignore a mob being agressively grabbed
#define IGNORE_GRAB (1<<2)

// Grouped effect sources, see also code/__DEFINES/traits.dm

#define STASIS_MACHINE_EFFECT "stasis_machine"

#define STASIS_CHEMICAL_EFFECT "stasis_chemical"

#define STASIS_ASCENSION_EFFECT "heretic_ascension"

// Status effect application helpers.

// adjust_x: Adds or removes duration of a status effect.
// adjust_x_up_to: Will only add or remove duration of a status effect up UNTIL the second parameter.
// set_stutter: Set the duration of a status effect exact.
// set_stutter_if_lower: Will only set the duration of that effect IF any existing duration is lower than what was passed.

#define adjust_stutter(duration) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter)
#define adjust_stutter_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter, up_to)
#define set_stutter(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter)
#define set_stutter_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter, TRUE)

#define adjust_derpspeech(duration) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech)
#define adjust_derpspeech_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech, up_to)
#define set_derpspeech(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech)
#define set_derpspeech_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/speech/stutter/derpspeech, TRUE)

#define adjust_slurring(duration) adjust_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk)
#define adjust_slurring_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk, up_to)
#define set_slurring(duration) set_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk)
#define set_slurring_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/speech/slurring/drunk, TRUE)

#define adjust_dizzy(duration) adjust_timed_status_effect(duration, /datum/status_effect/dizziness)
#define adjust_dizzy_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/dizziness, up_to)
#define set_dizzy(duration) set_timed_status_effect(duration, /datum/status_effect/dizziness)
#define set_dizzy_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/dizziness, TRUE)

#define adjust_jitter(duration) adjust_timed_status_effect(duration, /datum/status_effect/jitter)
#define adjust_jitter_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/jitter, up_to)
#define set_jitter(duration) set_timed_status_effect(duration, /datum/status_effect/jitter)
#define set_jitter_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/jitter, TRUE)

#define adjust_confusion(duration) adjust_timed_status_effect(duration, /datum/status_effect/confusion)
#define adjust_confusion_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/confusion, up_to)
#define set_confusion(duration) set_timed_status_effect(duration, /datum/status_effect/confusion)
#define set_confusion_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/confusion, TRUE)

#define adjust_drugginess(duration) adjust_timed_status_effect(duration, /datum/status_effect/drugginess)
#define adjust_drugginess_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/drugginess, up_to)
#define set_drugginess(duration) set_timed_status_effect(duration, /datum/status_effect/drugginess)
#define set_drugginess_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/drugginess, TRUE)

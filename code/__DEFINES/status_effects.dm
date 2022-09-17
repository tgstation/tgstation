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

#define STASIS_SHAPECHANGE_EFFECT "stasis_shapechange"

#define adjust_drowsiness(duration) adjust_timed_status_effect(duration, /datum/status_effect/drowsiness)
#define adjust_drowsiness_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/drowsiness, up_to)
#define set_drowsiness(duration) set_timed_status_effect(duration, /datum/status_effect/drowsiness)
#define set_drowsiness_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/drowsiness, TRUE)

#define adjust_eye_blur(duration) adjust_timed_status_effect(duration, /datum/status_effect/eye_blur)
#define adjust_eye_blur_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/eye_blur, up_to)
#define set_eye_blur(duration) set_timed_status_effect(duration, /datum/status_effect/eye_blur)
#define set_eye_blur_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/eye_blur, TRUE)

#define adjust_temp_blindness(duration) adjust_timed_status_effect(duration, /datum/status_effect/temporary_blindness)
#define adjust_temp_blindness_up_to(duration, up_to) adjust_timed_status_effect(duration, /datum/status_effect/temporary_blindness, up_to)
#define set_temp_blindness(duration) set_timed_status_effect(duration, /datum/status_effect/temporary_blindness)
#define set_temp_blindness_if_lower(duration) set_timed_status_effect(duration, /datum/status_effect/temporary_blindness, TRUE)

#define is_blind(mob) (isliving(mob) ? mob:has_status_effect(/datum/status_effect/grouped/visually_impaired/blindness) : FALSE)


#define is_blind_from(source) has_status_effect_from_source(/datum/status_effect/grouped/visually_impaired/blindness, source)
#define become_blind(source) apply_status_effect(/datum/status_effect/grouped/visually_impaired/blindness, source)
#define cure_blind(source) remove_status_effect(/datum/status_effect/grouped/visually_impaired/blindness, source)

#define is_nearsighted(mob) (isliving(mob) ? mob:has_status_effect(/datum/status_effect/grouped/visually_impaired/nearsighted) : FALSE)
#define is_nearsighted_currently(mob) (!HAS_TRAIT(mob, TRAIT_NEARSIGHTED_CORRECTED) && mob.has_status_effect(/datum/status_effect/grouped/visually_impaired/nearsighted))
#define is_nearsighted_from(source) has_status_effect_from_source(/datum/status_effect/grouped/visually_impaired/nearsighted, source)
#define become_nearsighted(source) apply_status_effect(/datum/status_effect/grouped/visually_impaired/nearsighted, source)
#define cure_nearsighted(source) remove_status_effect(/datum/status_effect/grouped/visually_impaired/nearsighted, source)

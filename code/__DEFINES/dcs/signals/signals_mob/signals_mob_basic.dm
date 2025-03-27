/// Sent from /mob/living/basic/proc/look_dead() : ()
#define COMSIG_BASICMOB_LOOK_DEAD "basicmob_look_dead"
/// Sent from /mob/living/basic/proc/look_alive() : ()
#define COMSIG_BASICMOB_LOOK_ALIVE "basicmob_look_alive"

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_BASICMOB_PRE_ATTACK_RANGED "basicmob_pre_attack_ranged"
	#define COMPONENT_CANCEL_RANGED_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //! Cancel to prevent the attack from happening

///from the ranged_attacks component for basic mobs: (mob/living/basic/firer, atom/target, modifiers)
#define COMSIG_BASICMOB_POST_ATTACK_RANGED "basicmob_post_attack_ranged"

/// Sent from /datum/ai_planning_subtree/parrot_as_in_repeat() : ()
#define COMSIG_NEEDS_NEW_PHRASE "parrot_needs_new_phrase"
	#define NO_NEW_PHRASE_AVAILABLE (1<<0) //! Cancel to try again later for when we actually get a new phrase

/// Called whenever an animal is pet via the /datum/element/pet_bonus element: (mob/living/petter, modifiers)
#define COMSIG_ANIMAL_PET "animal_pet"

///from base of mob/living/basic/regal_rat: (mob/living/basic/regal_rat/king)
#define COMSIG_RAT_INTERACT "rat_interaction"
	#define COMPONENT_RAT_INTERACTED (1<<0) //! If this is returned, cancel any further interactions.

///from /datum/status_effect/slime_leech: (mob/living/basic/slime/draining_slime)
#define COMSIG_SLIME_DRAINED "slime_drained"


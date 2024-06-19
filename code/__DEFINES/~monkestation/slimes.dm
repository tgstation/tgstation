#define ADULT_SLIME (1<<0)
#define PASSIVE_SLIME (1<<1)
#define STORED_SLIME (1<<2)
#define MUTATING_SLIME (1<<3)
#define SPLITTING_SLIME (1<<4)
#define CLEANER_SLIME (1<<5)
#define OVERWRITES_COLOR (1<<6)
#define NOEVOLVE_SLIME (1<<7)
#define NOOOZE_SLIME (1<<8)

#define TRAIT_ON_DEATH (1<<0)
#define TRAIT_VISUAL (1<<1)

#define TRAIT_MUTATOR_USED "mutator_trait"
#define TRAIT_IN_STACK "inside_mob_stack"
#define TRAIT_FEEDING "feeding_trait"
#define LATCH_TRAIT "latch_trait"
#define TRAIT_LATCH_FEEDERED "feeder_targetted"

#define BB_BASIC_MOB_SCARED_ITEM "BB_basic_mob_scared_item"
#define BB_WONT_TARGET_CLIENTS "BB_wont_target_clients"

#define TRAIT_CAREFUL_STEPS "careful_steps"
#define TRAIT_LIGHTWEIGHT "lightweight"
#define TRAIT_SLIME_STASIS "slime_stasis"
#define TRAIT_SLIME_RABID "slime_rabid"
#define TRAIT_SLIME_DUST_IMMUNE "slime_dust_immune"
#define COMSIG_ATOM_SUCKED "atom_sucked"

#define TRAIT_OVERFED "overfed_trait"
#define VACPACK_THROW "vacpack_throw"

///from obj/item/vacuum_nozzle/afterattack(atom/movable/target, mob/user, proximity, params): (obj/item/vacuum_nozzle/nozzle, mob/user)
#define COMSIG_LIVING_VACUUM_PRESUCK "living_vacuum_presuck"
	#define COMPONENT_LIVING_VACUUM_CANCEL_SUCK (1<<0)

#define SLIME_VALUE_TIER_1 200
#define SLIME_VALUE_TIER_2 400
#define SLIME_VALUE_TIER_3 800
#define SLIME_VALUE_TIER_4 1600
#define SLIME_VALUE_TIER_5 3200
#define SLIME_VALUE_TIER_6 6400
#define SLIME_VALUE_TIER_7 12800

#define SLIME_SELL_MODIFIER_MIN 	  -0.08
#define SLIME_SELL_MODIFIER_MAX 	  -0.01
#define SLIME_SELL_OTHER_MODIFIER_MIN 0.005
#define SLIME_SELL_OTHER_MODIFIER_MAX 0.01
#define SLIME_SELL_MAXIMUM_MODIFIER   2
#define SLIME_SELL_MINIMUM_MODIFIER   0.1
#define SLIME_RANDOM_MODIFIER_MIN -0.0003
#define SLIME_RANDOM_MODIFIER_MAX 0.0003

/// How many units of slime ooze are required for a normal extract recipe.
#define EXTRACT_RECIPE_OOZE_AMOUNT			20
/// How many units of slime ooze (of each color) are required for a crossbreed recipe.
#define CROSSBREED_RECIPE_OOZE_AMOUNT		250
/// How many units of slime ooze (of each color) are required for an regenerative crossbreed recipe.
#define REGEN_CROSSBREED_RECIPE_OOZE_AMOUNT	500

#define EMOTION_HAPPY "happy"
#define EMOTION_SAD "sad"
#define EMOTION_SCARED "scared"
#define EMOTION_FUNNY "funny"
#define EMOTION_ANGER "anger"
#define EMOTION_SUPRISED "suprised"
#define EMOTION_HUNGRY "hungry"

#define FOOD_CHANGE "food_change"
#define ENVIRONMENT_CHANGE "enviro_change"
#define BEHAVIOUR_CHANGE "behaviour_change"
#define DANGEROUS_CHANGE "dangerous_change"
#define DOCILE_CHANGE "docile_change"

#define FRIENDSHIP_HATED "hated"
#define FRIENDSHIP_DISLIKED "disliked"
#define FRIENDSHIP_STRANGER "stranger"
#define FRIENDSHIP_NEUTRAL "neutral"
#define FRIENDSHIP_ACQUAINTANCES "acquaintances"
#define FRIENDSHIP_FRIEND "friend"
#define FRIENDSHIP_BESTFRIEND "bestfriend"

#define COMSIG_FRIENDSHIP_CHECK_LEVEL "friendship_check_level"
#define COMSIG_FRIENDSHIP_CHANGE "friendship_change"
#define COMSIG_FRIENDSHIP_PASS_FRIENDSHIP "friendship_passfriends"

#define TRAIT_RAINBOWED "rainbowed"

#define COMSIG_ATOM_MOUSE_ENTERED "mouse_entered"
#define COMSIG_CLIENT_HOVER_NEW "client_new_hover"

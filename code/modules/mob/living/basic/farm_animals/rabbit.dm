/**
 * ## Rabbit
 *
 * A creature that hops around with small tails and long ears.
 *
 * This contains the code for both your standard rabbit as well as the subtypes commonly found during Easter.
 *
 */
/mob/living/basic/rabbit
	name = "rabbit"
	desc = "The hippiest hop around."
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white"
	icon_living = "rabbit_white"
	icon_dead = "rabbit_white_dead"
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	health = 15
	maxHealth = 15
	density = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN
	speak_emote = list("sniffles", "twitches")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	butcher_results = list(/obj/item/food/meat/slab = 1)
	ai_controller = /datum/ai_controller/basic_controller/rabbit
	/// passed to animal_varity as the prefix icon.
	var/icon_prefix = "rabbit"

/mob/living/basic/rabbit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "hops around happily!")
	AddElement(/datum/element/animal_variety, icon_prefix, pick("brown", "black", "white"), TRUE)
	if(prob(20)) // bunny
		name = "bunny"

/mob/living/basic/rabbit/add_environment_elements()
	AddElement(/datum/element/atmos_requirements, GLOB.basic_atmos_requirements, 1)
	AddElement(/datum/element/basic_body_temp_sensitive, 250, 350, 0.5, 0.5)

/datum/ai_controller/basic_controller/rabbit
	blackboard = list(
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)
	ai_traits = STOP_MOVING_WHEN_PULLED | STOP_ACTING_WHILE_DEAD
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/rabbit,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		)


/// The easter subtype of rabbits, will lay eggs and say Eastery catchphrases.
/mob/living/basic/rabbit/easter
	icon_state = "easter_rabbit_white"
	icon_living = "easter_rabbit_white"
	icon_dead = "easter_rabbit_white_dead"
	icon_prefix = "easter_rabbit"
	ai_controller = /datum/ai_controller/basic_controller/rabbit/easter
	///passed to the egg_layer component as how many eggs it starts out as able to lay.
	var/initial_egg_amount = 10
	///passed to the egg_layer component as how many eggs it's allowed to hold at most.
	var/max_eggs_held = 8

/mob/living/basic/rabbit/easter/Initialize(mapload)
	. = ..()
	//passed to the egg_layer component as how many eggs it gets when it eats something.
	var/eggs_added_from_eating = rand(1, 4)
	var/list/feed_messages = list("[p_they()] nibbles happily.", "[p_they()] noms happily.")
	AddComponent(/datum/component/egg_layer,\
		/obj/item/surprise_egg,\
		list(/obj/item/food/grown/carrot),\
		feed_messages,\
		list("hides an egg.","scampers around suspiciously.","begins making a huge racket.","begins shuffling."),\
		initial_egg_amount,\
		eggs_added_from_eating,\
		max_eggs_held,\
	)

/datum/ai_controller/basic_controller/rabbit/easter
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/rabbit/easter,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		)


/// Same deal as the standard easter subtype, but these ones are able to brave the cold of space with their handy gas mask.
/mob/living/basic/rabbit/easter/space
	icon_state = "space_rabbit_white"
	icon_living = "space_rabbit_white"
	icon_dead = "space_rabbit_white_dead"
	icon_prefix = "space_rabbit"
	ai_controller = /datum/ai_controller/basic_controller/rabbit/easter/space

/mob/living/basic/rabbit/easter/space/add_environment_elements()
	//no atmos, suspiciously high temperature to take damage
	AddElement(/datum/element/basic_body_temp_sensitive, 0, 1500, 0, 0.5)

/datum/ai_controller/basic_controller/rabbit/easter/space
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/rabbit/easter/space,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

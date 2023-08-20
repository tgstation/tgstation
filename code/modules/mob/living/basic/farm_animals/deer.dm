/mob/living/basic/deer
	name = "doe"
	desc = "A gentle, peaceful forest animal. How did this get into space?"
	icon_state = "deer-doe"
	icon_living = "deer-doe"
	icon_dead = "deer-doe-dead"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("grunts", "grunts lowly")
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently nudges"
	response_disarm_simple = "gently nudges aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "bucks"
	attack_verb_simple = "buck"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 75
	maxHealth = 75
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/deer
	/// Things that will scare us into being stationary. Vehicles are scary to deers because they might have headlights.
	var/static/list/stationary_scary_things = list(/obj/vehicle)

/mob/living/basic/deer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)
	var/time_to_freeze_for = (rand(5, 10) SECONDS)
	ai_controller.set_blackboard_key(BB_STATIONARY_SECONDS, time_to_freeze_for)
	ai_controller.set_blackboard_key(BB_STATIONARY_COOLDOWN, (time_to_freeze_for * (rand(3, 5))))
	ai_controller.set_blackboard_key(BB_STATIONARY_TARGETS, stationary_scary_things)

/datum/ai_controller/basic_controller/deer
	blackboard = list(
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_STATIONARY_MOVE_TO_TARGET = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/deer,
		/datum/ai_planning_subtree/stare_at_thing,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

/// Cold resistent and doesn't need to breathe
/mob/living/basic/deer/ice
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0

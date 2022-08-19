/mob/living/basic/sheep
	name = "sheep"
	desc = "Known for their soft wool and use in sacrifical rituals. Big fan of grass."
	icon = 'icons/mob/sheep.dmi'
	icon_state = "sheep"
	icon_state = "sheep"
	icon_dead = "sheep_dead"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("baas","bleats")
	speed = 1.1
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/sheep

/mob/living/basic/sheep/Initialize(mapload)
    AddComponent(/datum/component/mob_harvest, /obj/item/mob_harvest/sheep)
    . = ..()

/datum/ai_controller/basic_controller/sheep
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/sheep
	)

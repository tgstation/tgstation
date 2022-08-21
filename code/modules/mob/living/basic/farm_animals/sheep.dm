/mob/living/basic/sheep
	name = "sheep"
	desc = "Known for their soft wool and use in sacrifical rituals. Big fan of grass."
	icon = 'icons/mob/sheep.dmi'
	icon_state = "sheep"
	icon_state = "sheep"
	icon_dead = "sheep_dead"
	var/cult_icon
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
	AddComponent(/datum/component/mob_harvest, /obj/item/razor, /obj/item/food/grown/grass, /obj/item/stack/sheet/cotton/wool, "soft wool", 10, 3 MINUTES, 30 SECONDS, 5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_HARVEST_UPDATE, .proc/wool_status)
	. = ..()

/mob/living/basic/sheep/proc/wool_status(atom/movable/source, amount_ready)
	SIGNAL_HANDLER

	if(amount_ready < 1)
		icon_state = "sheep_harvested"
		update_icon()
	else
		icon_state = "sheep"
		update_icon()

/mob/living/basic/sheep/proc/cult_time()
	if(!cult_icon)
		say("BAAAAAAAAH!")
		cult_icon = mutable_appearance('icons/mob/sheep.dmi', "hat")
		add_overlay(cult_icon)


/datum/ai_controller/basic_controller/sheep
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/sheep
	)

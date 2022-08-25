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
	var/cult_converted //were we sacrificed by cultists?

/mob/living/basic/sheep/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/mob_harvest, /obj/item/razor, /obj/item/food/grown/grass, /obj/item/stack/sheet/cotton/wool, "soft wool", 10, 3 MINUTES, 30 SECONDS, 5 SECONDS)
	RegisterSignal(src, COMSIG_LIVING_HARVEST_UPDATE, .proc/update_harvest_icon)
	update_appearance(UPDATE_ICON)

/mob/living/basic/sheep/proc/update_harvest_icon()
	SIGNAL_HANDLER
	update_appearance(UPDATE_ICON)

/mob/living/basic/sheep/update_icon_state()
	. = ..()
	var/datum/component/mob_harvest/harvest_comp = GetComponent(/datum/component/mob_harvest)
	icon_state = "[initial(icon_state)][harvest_comp.amount_ready < 1 ? "_harvested" : null]"

/mob/living/basic/sheep/update_overlays()
	. = ..()
	if(stat == DEAD)
		return
	if(cult_converted)
		. += "hat"

/mob/living/basic/sheep/proc/cult_time()
	if(cult_converted)
		return
	cult_converted = TRUE
	say("BAAAAAAAAH!")
	update_appearance(UPDATE_ICON)

/mob/living/basic/sheep/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, cult_converted))
		if(vval == cult_converted)
			return FALSE
		if(vval)
			cult_time()
		..()
		if(!cult_converted)
			update_appearance(UPDATE_ICON)
		return TRUE
	return ..()

/datum/ai_controller/basic_controller/sheep
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/sheep
	)

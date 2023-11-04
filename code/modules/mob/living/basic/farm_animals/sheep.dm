/mob/living/basic/sheep
	name = "sheep"
	desc = "Known for their soft wool and use in sacrifical rituals. Big fan of grass."
	icon = 'icons/mob/simple/sheep.dmi'
	icon_state = "sheep"
	icon_dead = "sheep_dead"
	base_icon_state = "sheep"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("baas","bleats")
	speed = 1.1
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 3)
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

	/// Were we sacrificed by cultists?
	var/cult_converted = FALSE

/mob/living/basic/sheep/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/mob_harvest, \
		harvest_tool = /obj/item/razor, \
		fed_item = /obj/item/food/grown/grass, \
		produced_item_typepath = /obj/item/stack/sheet/cotton/wool, \
		produced_item_desc = "soft wool", \
		max_ready = 10, \
		item_generation_wait = 3 MINUTES, \
		item_reduction_time = 30 SECONDS, \
		item_harvest_time = 5 SECONDS, \
		item_harvest_sound = 'sound/surgery/scalpel1.ogg', \
	)
	AddElement(/datum/element/ai_retaliate)
	RegisterSignal(src, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_sacrificed))

/mob/living/basic/sheep/update_overlays()
	. = ..()
	if(stat == DEAD)
		return
	if(cult_converted)
		. += "hat"

/// Signal proc for [COMSIG_LIVING_CULT_SACRIFICED] to have special interaction with sacrificing a lamb
/mob/living/basic/sheep/proc/on_sacrificed(datum/source, list/invokers)
	SIGNAL_HANDLER

	if(cult_converted)
		for(var/mob/living/cultist as anything in invokers)
			to_chat(cultist, span_cultitalic("[src] has already been sacrificed!"))
		return STOP_SACRIFICE

	for(var/mob/living/cultist as anything in invokers)
		to_chat(cultist, span_cultitalic("This feels a bit too cliché, don't you think?"))

	cult_converted = TRUE
	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), "BAAAAAAAAH!")
	update_appearance(UPDATE_ICON)
	return STOP_SACRIFICE

/mob/living/basic/sheep/vv_edit_var(vname, vval)
	if(vname != NAMEOF(src, cult_converted))
		return ..()

	if(vval == cult_converted)
		return FALSE
	. = ..()
	if(.)
		update_appearance(UPDATE_ICON)

/datum/ai_controller/basic_controller/sheep
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/sheep,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

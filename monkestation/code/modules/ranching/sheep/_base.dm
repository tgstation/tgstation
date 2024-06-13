/mob/living/basic/sheep
	name = "sheep"
	desc = "Known for their soft wool and use in sacrifical rituals. Big fan of grass."
	icon = 'monkestation/code/modules/ranching/icons/sheep.dmi'
	icon_state = "base_white"
	icon_dead = "dead_white"
	base_icon_state = "base_white"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_emote = list("baas","bleats")
	speed = 1.1
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

	/// Were we sacrificed by cultists?
	var/cult_converted = FALSE
	var/wool_icon_state = "wool"
	///our output path
	var/output = /obj/item/stack/sheet/cotton/wool
	var/color_mut
	var/list/breeding_types = list(/mob/living/basic/sheep)

/mob/living/basic/sheep/Initialize(mapload)
	. = ..()
	set_icon_states()
	if(prob(33))
		gender = MALE
	else
		AddComponent(/datum/component/mutation, list(), FALSE)
		AddComponent(/datum/component/breed, can_breed_with = breeding_types, override_baby = CALLBACK(src, PROC_REF(baby_creation)))

	AddComponent(/datum/component/shearable, output, 1, 5 MINUTES, 'monkestation/code/modules/ranching/icons/sheep.dmi', wool_icon_state, CALLBACK(src, PROC_REF(regrow)), CALLBACK(src, PROC_REF(on_shear)))
	AddElement(/datum/element/ai_retaliate)
	RegisterSignal(src, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_sacrificed))
	update_appearance()
/mob/living/basic/sheep/update_overlays()
	. = ..()
	if(gender == MALE)
		. += mutable_appearance(icon, "horns", layer + 0.1, src, appearance_flags = RESET_COLOR)
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

/mob/living/basic/sheep/proc/regrow()
	return

/mob/living/basic/sheep/proc/on_shear()
	return

/mob/living/basic/sheep/proc/set_icon_states()
	if(color_mut)
		icon_dead = "dead_greyscale"
		icon_living = "base_greyscale"
		base_icon_state = "base_greyscale"
		color = color_mut
	else
		if(prob(50))
			icon_dead = "dead_black"
			icon_living = "base_black"
			base_icon_state = "base_black"
		else
			icon_dead = "dead_white"
			icon_living = "base_white"
			base_icon_state = "base_white"

/mob/living/basic/sheep/proc/baby_creation()
	SEND_SIGNAL(src, COMSIG_MUTATION_TRIGGER, get_turf(src), TRUE, 25)

/datum/ai_controller/basic_controller/sheep
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/sheep,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
	)

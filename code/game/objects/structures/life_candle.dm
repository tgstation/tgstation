/obj/structure/life_candle
	name = "life candle"
	desc = "You are dead. Insert quarter to continue."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	light_system = OVERLAY_LIGHT
	light_color = LIGHT_COLOR_FIRE
	light_power = 1.5
	light_range = 2
	light_on = FALSE

	var/icon_state_active = "candle1_lit"
	var/icon_state_inactive = "candle1"

	anchored = TRUE

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/lit_luminosity = 2
	var/list/datum/mind/linked_minds = list()

	// If the body is destroyed, what do we spawn for them
	var/mob_type = /mob/living/carbon/human

	// If the respawned person is given a specific outfit
	var/datum/outfit/outfit
	// How long until we respawn them after their death.
	var/respawn_time = 50
	var/respawn_sound = 'sound/effects/magic/staff_animation.ogg'
	/// Lighting middleman, lets us do a flicker effect
	var/datum/light_middleman/middleman

/obj/structure/life_candle/Initialize(mapload)
	. = ..()
	if(IS_OVERLAY_LIGHT_SYSTEM(light_system))
		middleman = new(src, "flashlight")
		RegisterSignal(middleman, COMSIG_LIGHT_MIDDLEMAN_UPDATED, PROC_REF(light_updated))
		middleman.being_overriding_light()
	AddElement(/datum/element/movetype_handler)

/obj/structure/life_candle/Destroy(force)
	QDEL_NULL(middleman)
	return ..()

/obj/structure/life_candle/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user.mind)
		return
	if(user.mind in linked_minds)
		user.visible_message(span_notice("[user] reaches out and pinches the flame of [src]."), span_warning("You sever the connection between yourself and [src]."))
		linked_minds -= user.mind
		if(!linked_minds.len)
			REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, LIFECANDLE_TRAIT)
	else
		if(!linked_minds.len)
			ADD_TRAIT(src, TRAIT_MOVE_FLOATING, LIFECANDLE_TRAIT)
		user.visible_message(span_notice("[user] touches [src]. It seems to respond to [user.p_their()] presence!"), span_warning("You create a connection between you and [src]."))
		linked_minds |= user.mind

	update_appearance()
	if(linked_minds.len)
		START_PROCESSING(SSobj, src)
		set_light_on(TRUE)
	else
		STOP_PROCESSING(SSobj, src)
		set_light_on(FALSE)

/obj/structure/life_candle/update_icon_state()
	icon_state = linked_minds.len ? icon_state_active : icon_state_inactive
	return ..()

/obj/structure/life_candle/examine(mob/user)
	. = ..()
	if(linked_minds.len)
		. += "[src] is active, and linked to [linked_minds.len] souls."
	else
		. += "It is static, still, unmoving."

/obj/structure/life_candle/process()
	if(!linked_minds.len)
		STOP_PROCESSING(SSobj, src)
		return

	for(var/m in linked_minds)
		var/datum/mind/mind = m
		if(!mind.current || (mind.current && mind.current.stat == DEAD))
			addtimer(CALLBACK(src, PROC_REF(respawn), mind), respawn_time, TIMER_UNIQUE)

/obj/structure/life_candle/proc/light_updated(datum/source)
	SIGNAL_HANDLER
	fire_flicker_middleman(middleman)

/obj/structure/life_candle/proc/respawn(datum/mind/mind)
	var/turf/T = get_turf(src)
	var/mob/living/body
	if(mind.current)
		if(mind.current.stat != DEAD)
			return
		else
			body = mind.current
	if(!body)
		body = new mob_type(T)
		var/mob/ghostie = mind.get_ghost(TRUE)
		ghostie.client?.prefs?.safe_transfer_prefs_to(body)
		mind.transfer_to(body)
	else
		body.forceMove(T)
		body.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE)
	body.flash_act()

	if(ishuman(body) && istype(outfit))
		outfit.equip(body)
	playsound(T, respawn_sound, 50, TRUE)

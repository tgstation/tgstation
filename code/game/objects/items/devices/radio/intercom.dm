/obj/item/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	dog_fashion = null
	unscrewed = FALSE
	item_flags = NO_BLOOD_ON_ITEM

	overlay_speaker_idle = "intercom_s"
	overlay_speaker_active = "intercom_recieve"

	overlay_mic_idle = "intercom_m"
	overlay_mic_active = null

/obj/item/radio/intercom/unscrewed
	unscrewed = TRUE

/obj/item/radio/intercom/prison
	name = "prison intercom"
	desc = "A station intercom. It looks like it has been modified to not broadcast."

/obj/item/radio/intercom/prison/Initialize(mapload, ndir, building)
	. = ..()
	wires?.cut(WIRE_TX)

/obj/item/radio/intercom/Initialize(mapload, ndir, building)
	. = ..()
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(AreaPowerCheck))
	GLOB.intercoms_list += src

/obj/item/radio/intercom/Destroy()
	. = ..()
	GLOB.intercoms_list -= src

/obj/item/radio/intercom/examine(mob/user)
	. = ..()
	. += span_notice("Use [MODE_TOKEN_INTERCOM] when nearby to speak into it.")
	if(!unscrewed)
		. += span_notice("It's <b>screwed</b> and secured to the wall.")
	else
		. += span_notice("It's <i>unscrewed</i> from the wall, and can be <b>detached</b>.")

	if(anonymize)
		. += span_notice("Speaking through this intercom will anonymize your voice.")

	if(freqlock == RADIO_FREQENCY_UNLOCKED)
		if(obj_flags & EMAGGED)
			. += span_warning("Its frequency lock has been shorted...")
	else
		. += span_notice("It has a frequency lock set to [frequency/10].")

/obj/item/radio/intercom/screwdriver_act(mob/living/user, obj/item/tool)
	if(unscrewed)
		user.visible_message(span_notice("[user] starts tightening [src]'s screws..."), span_notice("You start screwing in [src]..."))
		if(tool.use_tool(src, user, 30, volume=50))
			user.visible_message(span_notice("[user] tightens [src]'s screws!"), span_notice("You tighten [src]'s screws."))
			unscrewed = FALSE
	else
		user.visible_message(span_notice("[user] starts loosening [src]'s screws..."), span_notice("You start unscrewing [src]..."))
		if(tool.use_tool(src, user, 40, volume=50))
			user.visible_message(span_notice("[user] loosens [src]'s screws!"), span_notice("You unscrew [src], loosening it from the wall."))
			unscrewed = TRUE
	return TRUE

/obj/item/radio/intercom/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!unscrewed)
		to_chat(user, span_warning("You need to unscrew [src] from the wall first!"))
		return
	user.visible_message(span_notice("[user] starts unsecuring [src]..."), span_notice("You start unsecuring [src]..."))
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 80))
		user.visible_message(span_notice("[user] unsecures [src]!"), span_notice("You detach [src] from the wall."))
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		new/obj/item/wallframe/intercom(get_turf(src))
		qdel(src)

/**
 * Override attack_tk_grab instead of attack_tk because we actually want attack_tk's
 * functionality. What we DON'T want is attack_tk_grab attempting to pick up the
 * intercom as if it was an ordinary item.
 */
/obj/item/radio/intercom/attack_tk_grab(mob/user)
	interact(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/item/radio/intercom/attack_ai(mob/user)
	interact(user)

/obj/item/radio/intercom/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	interact(user)

/obj/item/radio/intercom/ui_state(mob/user)
	return GLOB.default_state

/obj/item/radio/intercom/can_receive(freq, list/levels)
	if(levels != RADIO_NO_Z_LEVEL_RESTRICTION)
		var/turf/position = get_turf(src)
		if(isnull(position) || !(position.z in levels))
			return FALSE

	if(freq == FREQ_SYNDICATE)
		if(!(syndie))
			return FALSE//Prevents broadcast of messages over devices lacking the encryption

	return TRUE

/obj/item/radio/intercom/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	if(message_mods[RADIO_EXTENSION] == MODE_INTERCOM)
		return  // Avoid hearing the same thing twice
	return ..()

/obj/item/radio/intercom/emp_act(severity)
	. = ..() // Parent call here will set `on` to FALSE.
	update_appearance()

/obj/item/radio/intercom/end_emp_effect(curremp)
	. = ..()
	AreaPowerCheck() // Make sure the area/local APC is powered first before we actually turn back on.

/obj/item/radio/intercom/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return

	switch(freqlock)
		// Emagging an intercom with an emaggable lock will remove the lock
		if(RADIO_FREQENCY_EMAGGABLE_LOCK)
			balloon_alert(user, "frequency lock cleared")
			playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)
			freqlock = RADIO_FREQENCY_UNLOCKED
			obj_flags |= EMAGGED

		// A fully locked one will do nothing, as locked is intended to be used for stuff that should never be changed
		if(RADIO_FREQENCY_LOCKED)
			balloon_alert(user, "can't override frequency lock!")
			playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE, SILENCED_SOUND_EXTRARANGE)

		// Emagging an unlocked one will do nothing, for now
		else
			return

	return ..()

/obj/item/radio/intercom/update_icon_state()
	icon_state = on ? initial(icon_state) : "intercom-p"
	return ..()

/**
 * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
 *
 * Normally called after the intercom's area recieves the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
 * Arguments:
 * * source - the area that just had a power change.
 */
/obj/item/radio/intercom/proc/AreaPowerCheck(datum/source)
	SIGNAL_HANDLER
	var/area/current_area = get_area(src)
	if(!current_area)
		set_on(FALSE)
	else
		set_on(current_area.powered(AREA_USAGE_EQUIP)) // set "on" to the equipment power status of our area.
	update_appearance()

//Created through the autolathe or through deconstructing intercoms. Can be applied to wall to make a new intercom on it!
/obj/item/wallframe/intercom
	name = "intercom frame"
	desc = "A ready-to-go intercom. Just slap it on a wall and screw it in!"
	icon_state = "intercom"
	result_path = /obj/item/radio/intercom/unscrewed
	pixel_shift = 26
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.75, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.25)

MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom, 26)

/obj/item/radio/intercom/chapel
	name = "Confessional intercom"
	desc = "Talk through this... to confess your many sins. Conceals your voice, to keep them secret."
	anonymize = TRUE
	freqlock = RADIO_FREQENCY_EMAGGABLE_LOCK

/obj/item/radio/intercom/chapel/Initialize(mapload, ndir, building)
	. = ..()
	set_frequency(1481)
	set_broadcasting(TRUE)

/obj/item/radio/intercom/command
	name = "command intercom"
	desc = "The command team's special extended-frequency intercom. Mostly just used for eavesdropping, gossiping about subordinates, and complaining about the higher-ups."
	icon_state = "intercom_command"
	freerange = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/prison, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/chapel, 26)
MAPPING_DIRECTIONAL_HELPERS(/obj/item/radio/intercom/command, 26)

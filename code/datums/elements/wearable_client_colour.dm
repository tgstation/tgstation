/// An element that adds a client colour to the wearer when equipped to the right slot, under the right conditions.
/datum/element/wearable_client_colour
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The typepath of the client_colour added when worn in the appropriate slot(s)
	var/datum/client_colour/colour_type
	///The slot(s) that enable the client colour
	var/equip_slots = NONE
	///For items that want costumizable client colours
	var/custom_colour
	///if forced is false, we check that the user has the TRAIT_SEE_WORN_COLOURS before adding the colour.
	var/forced = FALSE
	///On examine, it'll tell which you have to press to toggle TRAIT_SEE_WORN_COLOURS.
	var/key_info = "Figure it out yourself how"

/datum/element/wearable_client_colour/Attach(obj/item/target, colour_type, equip_slots, custom_colour, forced = FALSE, comsig_toggle = COMSIG_CLICK_ALT)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

	src.colour_type = colour_type
	src.equip_slots = equip_slots
	src.custom_colour = custom_colour
	src.forced = forced

	if(!forced)
		switch(comsig_toggle)
			if(COMSIG_CLICK_ALT)
				key_info = EXAMINE_HINT("Alt-Click")
			if(COMSIG_CLICK_ALT_SECONDARY)
				key_info = EXAMINE_HINT("Right-Alt-Click")
			if(COMSIG_CLICK_CTRL)
				key_info = EXAMINE_HINT("Ctrl-Click")
			if(COMSIG_CLICK_CTRL_SHIFT)
				key_info = EXAMINE_HINT("Ctrl-Shift-Click")
			else
				stack_trace("Unsupported comsig_toggle arg value ([comsig_toggle]) for [type], defaulting to [COMSIG_CLICK_ALT]")
				key_info = EXAMINE_HINT("Alt-Click")
				comsig_toggle = COMSIG_CLICK_ALT
		RegisterSignal(target, comsig_toggle, PROC_REF(toggle_see_worn_colors))
		RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	if(ismob(target.loc))
		var/mob/wearer = target.loc
		if(wearer.get_slot_by_item(target) & equip_slots)
			try_client_colour(wearer)

/datum/element/wearable_client_colour/Detach(obj/item/source)
	var/list/fairly_long_list = list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_CLICK_ALT,
		COMSIG_CLICK_ALT_SECONDARY,
		COMSIG_CLICK_CTRL,
		COMSIG_CLICK_CTRL_SHIFT,
		COMSIG_ATOM_EXAMINE,
		)
	UnregisterSignal(source, fairly_long_list)
	if(ismob(source.loc))
		var/mob/wearer = source.loc
		if(wearer.get_slot_by_item(source) & equip_slots)
			remove_client_colour(wearer)
	return ..()

/datum/element/wearable_client_colour/proc/on_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot & equip_slots)
		try_client_colour(equipper)

/datum/element/wearable_client_colour/proc/on_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER
	remove_client_colour(dropper)

/datum/element/wearable_client_colour/proc/try_client_colour(mob/equipper)
	if(!forced)
		RegisterSignal(equipper, SIGNAL_ADDTRAIT(TRAIT_SEE_WORN_COLOURS), PROC_REF(on_trait_added))
		RegisterSignal(equipper, SIGNAL_REMOVETRAIT(TRAIT_SEE_WORN_COLOURS), PROC_REF(on_trait_removed))
		if(!HAS_TRAIT(equipper, TRAIT_SEE_WORN_COLOURS))
			return
	apply_client_colour(equipper)

/datum/element/wearable_client_colour/proc/on_trait_added(mob/source, trait)
	SIGNAL_HANDLER
	apply_client_colour(source)

/datum/element/wearable_client_colour/proc/apply_client_colour(mob/equipper)
	var/datum/client_colour/colour_to_add = colour_type
	if(custom_colour)
		colour_to_add = new colour_to_add
		colour_to_add.colour = custom_colour
	equipper.add_client_colour(colour_to_add)

/datum/element/wearable_client_colour/proc/on_trait_removed(mob/source, trait)
	SIGNAL_HANDLER
	source.remove_client_colour(colour_type)

/datum/element/wearable_client_colour/proc/remove_client_colour(mob/dropper)
	if(!forced)
		UnregisterSignal(dropper, list(SIGNAL_ADDTRAIT(TRAIT_SEE_WORN_COLOURS), SIGNAL_REMOVETRAIT(TRAIT_SEE_WORN_COLOURS)))
		if(!HAS_TRAIT(dropper, TRAIT_SEE_WORN_COLOURS))
			return
	dropper.remove_client_colour(colour_type)

/datum/element/wearable_client_colour/proc/toggle_see_worn_colors(obj/item/source, mob/clicker)
	SIGNAL_HANDLER
	if(source.loc != clicker || HAS_TRAIT(clicker, TRAIT_INCAPACITATED))
		return
	if(HAS_TRAIT(clicker, TRAIT_SEE_WORN_COLOURS))
		REMOVE_TRAIT(clicker, TRAIT_SEE_WORN_COLOURS, CLOTHING_TRAIT)
		clicker.balloon_alert(clicker, "glasses colors disabled")
	else
		ADD_TRAIT(clicker, TRAIT_SEE_WORN_COLOURS, CLOTHING_TRAIT)
		clicker.balloon_alert(clicker, "glasses colors enabled")
	return CLICK_ACTION_SUCCESS

/datum/element/wearable_client_colour/proc/on_examine(obj/item/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER
	examine_texts += span_info("While holding or wearing it, [key_info] to toggle on/off the screen color from glasses and such.")

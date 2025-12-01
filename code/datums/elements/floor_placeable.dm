/**
 * Simple behaviour for allowing the item to be placed on a specific position on an open turf by clicking there.
 */
/datum/element/floor_placeable

/datum/element/floor_placeable/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))
	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_interact_with_atom))

/datum/element/floor_placeable/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_ATOM_EXAMINE_TAGS,
		COMSIG_ITEM_INTERACTING_WITH_ATOM,
	))

/datum/element/floor_placeable/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list["floor placeable"] = "This item can be placed directly on the floor."

/datum/element/floor_placeable/proc/on_interact_with_atom(obj/item/source, mob/living/user, atom/interacting_with, list/modifiers)
	SIGNAL_HANDLER
	if(!isopenturf(interacting_with))
		return NONE
	if(user.combat_mode)
		return NONE
	if(source.item_flags & ABSTRACT)
		return NONE

	var/x_offset = 0
	var/y_offset = 0
	// Items are centered by default, but we move them if click ICON_X and ICON_Y are available
	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		// Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the turf)
		x_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X*0.5), ICON_SIZE_X*0.5)
		y_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y*0.5), ICON_SIZE_Y*0.5)

	if(!user.transfer_item_to_turf(source, interacting_with, x_offset, y_offset, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

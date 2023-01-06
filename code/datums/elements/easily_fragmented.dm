/*
 * An element for making tools fragile, giving them a chance of
 * "snapping into tiny pieces" after they've been used.
 */

/datum/element/easily_fragmented
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	var/break_chance

/datum/element/easily_fragmented/Attach(datum/target, break_chance)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.break_chance = break_chance

	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/element/easily_fragmented/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_AFTERATTACK)

/datum/element/easily_fragmented/proc/on_afterattack(datum/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	var/obj/item/item = source

	if(prob(break_chance))
		user.visible_message(span_danger("[user]'s [item.name] snap[item.p_s()] into tiny pieces in [user.p_their()] hand."))
		item.deconstruct(disassembled = FALSE)

	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

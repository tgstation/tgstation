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
	RegisterSignal(target, COMSIG_ITEM_TOOL_ACTED, PROC_REF(on_tool_use))

/datum/element/easily_fragmented/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_TOOL_ACTED))

/datum/element/easily_fragmented/proc/on_afterattack(datum/source, atom/target, mob/user, click_parameters)
	SIGNAL_HANDLER
	try_break(source, user)

/datum/element/easily_fragmented/proc/on_tool_use(datum/source, atom/target, mob/user, tool_type, result)
	SIGNAL_HANDLER
	try_break(source, user)

/datum/element/easily_fragmented/proc/try_break(obj/item/source, mob/user)
	if(prob(break_chance))
		user.visible_message(span_danger("[user]'s [source.name] snap[source.p_s()] into tiny pieces in [user.p_their()] hand."))
		source.deconstruct(disassembled = FALSE)

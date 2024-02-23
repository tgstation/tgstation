/**
 * Uplink Reimburse element.
 * When element is applied onto items, it allows them to be reimbursed if an user pokes an item with a uplink component with them.
 *
 * Element is only compatible with items.
 */

/datum/element/uplink_reimburse
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 1
	/// TC to refund!
	var/refundable_tc = 1

/datum/element/uplink_reimburse/Attach(datum/target, refundable_tc = 1)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.refundable_tc = refundable_tc

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_ATTEMPT_TC_REIMBURSE, PROC_REF(reimburse))
	RegisterSignal(target,COMSIG_TRAITOR_ITEM_USED(target.type), PROC_REF(used))

/datum/element/uplink_reimburse/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ATOM_EXAMINE, COMSIG_TRAITOR_ITEM_USED(target.type), COMSIG_ITEM_ATTEMPT_TC_REIMBURSE))


	return ..()

///signal called on parent being examined
/datum/element/uplink_reimburse/proc/on_examine(datum/target, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!IS_TRAITOR(user) && !IS_NUKE_OP(user))
		examine_list += span_warning("There's a label on the side, but it's written in indecipherable gibberish. You have no idea what it means!")
		return

	examine_list += span_notice("There's a label written in codespeak on the side, saying that this item can be refunded for [refundable_tc] by applying it onto an uplink.")

/datum/element/uplink_reimburse/proc/reimburse(obj/item/refund_item, mob/user, datum/component/uplink/uplink_comp)
	SIGNAL_HANDLER

	if(!uplink_comp)
		CRASH("No uplink component in arguments detected")

	to_chat(user, span_notice("You tap [uplink_comp.uplink_handler] with [refund_item], and a moment after [refund_item] disappears in a puff of red smoke!"))
	do_sparks(2, source = uplink_comp.uplink_handler)
	uplink_comp.uplink_handler.add_telecrystals(refundable_tc)
	qdel(refund_item)

/// If the item is used, it needs to no longer be refundable
/datum/element/uplink_reimburse/proc/used(datum/target)
	SIGNAL_HANDLER

	Detach(target)

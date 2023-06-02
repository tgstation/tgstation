
/**
 * Uplinik Reimburse element.
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
		stack_trace("uplink_reimburse element added to non-item object: \[[target]\]")
		return ELEMENT_INCOMPATIBLE

	src.refundable_tc = refundable_tc

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_ATTEMPT_TC_REIMBURSE, PROC_REF(reimburse))
	// Due to how our attack chain is terrible and doesn't have some sort of usable inverted attackby() apparently the best method here is
	// to just make the uplink component check for this element. Yay.

/datum/element/uplink_reimburse/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))

	return ..()

///signal called on parent being examined
/datum/element/uplink_reimburse/proc/on_examine(datum/target, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/examine_string

	if(!IS_TRAITOR(user) && !IS_NUKE_OP(user))
		examine_string = "There's a label on the side, but it's written in indecipherable gibberish. You have no idea what it means!"
		return

	examine_string = "There's a label written in codespeak on the side, saying that this item can be refunded for [refundable_tc] by applying it onto an uplink."

	examine_list += span_notice(examine_string)

/datum/element/uplink_reimburse/proc/reimburse(datum/target, mob/user)
	SIGNAL_HANDLER

	return refundable_tc

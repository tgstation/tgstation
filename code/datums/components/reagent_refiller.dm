/**
 * ## Reagent refiller
 * Refills any drinks poured out of the reagent container (and is allowed within the whitelisted reagents).
 */
/datum/component/reagent_refiller
	/// Time to refill
	var/time_to_refill
	/// Callback to consume power
	var/datum/callback/power_draw_callback
	/// Amount of power to use from the cell
	var/power_to_draw
	/// Whitelist of reagents allowed to be synthesized
	var/list/whitelisted_reagents

/datum/component/reagent_refiller/Initialize(
	time_to_refill = 60 SECONDS,
	datum/callback/power_draw_callback,
	power_to_draw = 30,
	whitelisted_reagents = list(/datum/reagent/consumable)
)
	if(!is_reagent_container(parent))
		return COMPONENT_INCOMPATIBLE

	src.time_to_refill = time_to_refill
	src.power_draw_callback = power_draw_callback
	src.power_to_draw = power_to_draw
	src.whitelisted_reagents = whitelisted_reagents

	return ..()

/datum/component/reagent_refiller/Destroy(force)
	power_draw_callback = null
	return ..()

/datum/component/reagent_refiller/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(refill))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(delete_self))

/datum/component/reagent_refiller/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_INTERACTING_WITH_ATOM, COMSIG_ATOM_EXITED))

/datum/component/reagent_refiller/proc/delete_self()
	SIGNAL_HANDLER

	qdel(src)

/// Preps the reagent container for being refilled
/datum/component/reagent_refiller/proc/refill()
	SIGNAL_HANDLER

	var/obj/item/reagent_containers/container = parent
	var/amount = min((container.amount_per_transfer_from_this + container.reagents.total_volume), container.reagents.total_volume)
	if (amount == 0)
		return

	var/datum/reagent/refill = container.reagents.get_master_reagent()
	if (!is_path_in_list(refill?.type, whitelisted_reagents))
		return

	addtimer(CALLBACK(src, PROC_REF(add_reagents), container, container.loc, refill.type, amount), time_to_refill)

/// Refills the reagent container, and uses cell power if applicable
/datum/component/reagent_refiller/proc/add_reagents(obj/item/reagent_containers/target, oldloc, reagent_to_refill, amount)
	if (QDELETED(src) || QDELETED(target))
		return
	if (target.loc != oldloc)
		return

	target.reagents.add_reagent(reagent_to_refill, amount)

	if (!isnull(power_draw_callback))
		power_draw_callback.Invoke(power_to_draw)

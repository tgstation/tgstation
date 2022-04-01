///Reagent refiller, refills any drinks .
/datum/element/reagent_refiller
	element_flags = ELEMENT_DETACH

	///Time to refill
	var/time_to_refill
	///Cell to use power of
	var/datum/weakref/cell_to_use
	///Amount of power to use from the cell
	var/power_to_draw
	///Whitelist of reagents allowed to be synthesized
	var/list/whitelisted_reagents

/datum/element/reagent_refiller/Attach(
	datum/target,
	time_to_refill = 5 SECONDS,
	obj/item/stock_parts/cell/cell,
	power_to_draw = 1000,
	whitelisted_reagents = list(/datum/reagent/consumable)
)
	. = ..()
	if(!istype(target, /obj/item/reagent_containers))
		return ELEMENT_INCOMPATIBLE

	src.time_to_refill = time_to_refill
	if (!isnull(cell))
		src.cell_to_use = WEAKREF(cell)
	src.power_to_draw = power_to_draw
	src.whitelisted_reagents = whitelisted_reagents

	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/refill)

/datum/element/reagent_refiller/Detach(datum/source, ...)
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	return ..()

/datum/element/reagent_refiller/proc/refill(obj/item/reagent_containers/target)
	SIGNAL_HANDLER

	var/refill = target.reagents.get_master_reagent_id()
	var/amount = min((target.amount_per_transfer_from_this + target.reagents.total_volume), target.reagents.total_volume)

	if (amount == 0)
		return
	if (!is_type_in_list(refill, whitelisted_reagents))
		return

	addtimer(CALLBACK(src, .proc/add_reagents, target, target.loc, refill, amount), time_to_refill)

/datum/element/reagent_refiller/proc/add_reagents(obj/item/reagent_containers/target, oldloc, reagent_to_refill, amount)
	if (target.loc != oldloc)
		return

	target.reagents.add_reagent(reagent_to_refill, amount)

	if (!isnull(cell_to_use))
		var/obj/item/stock_parts/cell/cell = cell_to_use.resolve()
		cell.use(power_to_draw)

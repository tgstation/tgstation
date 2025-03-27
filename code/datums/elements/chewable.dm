/// Anything with this element will provide the reagents inside the
/// item to the user when it is equipped.
/datum/element/chewable
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// The amount to metabolize per second
	var/metabolization_amount = REAGENTS_METABOLISM

	/// A bitfield of valid slots. If this is not provided, then it will
	/// use the `slot_flags` of the item.
	var/slots_to_check

	/// The objects with this element that are currently being processed
	var/list/processing = list()

/datum/element/chewable/Attach(datum/target, metabolization_amount, slots_to_check)
	. = ..()
	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	var/obj/item/target_item = target

	if (metabolization_amount)
		// this prevents microdosing which causes the reagent to enter and then delete itself before it can be processed
		if(metabolization_amount < REAGENTS_METABOLISM)
			CRASH("Attatching /datum/element/chewable to [target] requires metabolization_amount to be higher than [REAGENTS_METABOLISM]u. The amount used was [metabolization_amount]u!")

		src.metabolization_amount = metabolization_amount

	src.slots_to_check = slots_to_check || target_item.slot_flags

	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))

/datum/element/chewable/Detach(datum/source, force)
	. = ..()
	processing -= source
	UnregisterSignal(source, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))

/datum/element/chewable/process(seconds_per_tick)
	if (processing.len == 0)
		return PROCESS_KILL

	for (var/obj/item/item as anything in processing)
		var/mob/chewer = item.loc

		if (!istype(chewer) || !item.reagents?.total_volume)
			processing -= item
			continue

		handle_reagents(item, seconds_per_tick)

/datum/element/chewable/proc/handle_reagents(obj/item/item, seconds_per_tick)
	var/datum/reagents/reagents = item.reagents

	var/metabolism_amount = metabolization_amount * seconds_per_tick
	if (!reagents.trans_to(item.loc, metabolism_amount, methods = INGEST))
		reagents.remove_all(metabolism_amount)

/datum/element/chewable/proc/on_dropped(datum/source)
	SIGNAL_HANDLER
	processing -= source

/datum/element/chewable/proc/on_equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (slot & slots_to_check)
		processing += source
		START_PROCESSING(SSdcs, src)
	else
		processing -= source

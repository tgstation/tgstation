// If an item has the dunkable element, it's able to be dunked into reagent containers like beakers and glasses.
// Dunking the item into a container will transfer reagents from the container to the item.
/datum/element/dunkable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/dunk_amount // the amount of reagents that will be transferred from the container to the item on each click

/datum/element/dunkable/Attach(datum/target, amount_per_dunk)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	dunk_amount = amount_per_dunk
	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(get_dunked))

/datum/element/dunkable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM)

/datum/element/dunkable/proc/get_dunked(datum/source, mob/user, atom/target, params)
	SIGNAL_HANDLER

	var/obj/item/reagent_containers/container = target // the container we're trying to dunk into
	if(istype(container) && (container.reagent_flags & DUNKABLE)) // container should be a valid target for dunking
		if(!container.is_drainable())
			to_chat(user, span_warning("[container] is unable to be dunked in!"))
			return ITEM_INTERACT_BLOCKING
		var/obj/item/I = source // the item that has the dunkable element
		if(container.reagents.trans_to(I, dunk_amount, transferred_by = user)) //if reagents were transferred, show the message
			to_chat(user, span_notice("You dunk \the [I] into \the [container]."))
			return ITEM_INTERACT_SUCCESS
		if(!container.reagents.total_volume)
			to_chat(user, span_warning("[container] is empty!"))
		else
			to_chat(user, span_warning("[I] is full!"))
		return ITEM_INTERACT_BLOCKING
	return NONE

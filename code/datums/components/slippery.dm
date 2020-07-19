/datum/component/slippery
	var/force_drop_items = FALSE
	var/knockdown_time = 0
	var/paralyze_time = 0
	var/lube_flags
	var/datum/callback/callback

/datum/component/slippery/Initialize(_knockdown, _lube_flags = NONE, datum/callback/_callback, _paralyze, _force_drop = FALSE)
	knockdown_time = max(_knockdown, 0)
	paralyze_time = max(_paralyze, 0)
	force_drop_items = _force_drop
	lube_flags = _lube_flags
	callback = _callback
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Slip)
	RegisterSignal(parent, COMSIG_ITEM_WEARERCROSSED, .proc/Slip_on_wearer)

/datum/component/slippery/proc/Slip(datum/source, atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && !victim.is_flying() && victim.slip(knockdown_time, parent, lube_flags, paralyze_time, force_drop_items) && callback)
		callback.Invoke(victim)


/datum/component/slippery/proc/Slip_on_wearer(datum/source, atom/movable/AM, mob/living/crossed)
	if(!(crossed.mobility_flags & MOBILITY_STAND) && !crossed.buckle_lying)
		Slip(source, AM)

/datum/component/slippery/clowning //used for making the clown PDA only slip if the clown is wearing his shoes and the elusive banana-skin belt

/datum/component/slippery/clowning/Slip_on_wearer(datum/source, atom/movable/AM, mob/living/crossed)
	var/obj/item/I = crossed.get_item_by_slot(ITEM_SLOT_FEET)
	if(!(crossed.mobility_flags & MOBILITY_STAND) && !crossed.buckle_lying)
		if(istype(I, /obj/item/clothing/shoes/clown_shoes))
			Slip(source, AM)
		else
			to_chat(crossed,"<span class='warning'>[parent] failed to slip anyone. Perhaps I shouldn't have abandoned my legacy...</span>")


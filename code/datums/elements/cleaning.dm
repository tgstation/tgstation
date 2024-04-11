/datum/element/cleaning

/datum/element/cleaning/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(clean))

/datum/element/cleaning/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/cleaning/proc/clean(datum/source)
	SIGNAL_HANDLER

	var/atom/movable/atom_movable = source
	var/turf/tile = atom_movable.loc
	if(!isturf(tile))
		return

	tile.wash(CLEAN_SCRUB)
	for(var/atom/cleaned as anything in tile)
		// Clean small items that are lying on the ground
		if(isitem(cleaned))
			var/obj/item/cleaned_item = cleaned
			if(cleaned_item.w_class <= WEIGHT_CLASS_SMALL)
				cleaned_item.wash(CLEAN_SCRUB)
			continue
		// Clean humans that are lying down
		if(!ishuman(cleaned))
			continue
		var/mob/living/carbon/human/cleaned_human = cleaned
		if(cleaned_human.body_position == LYING_DOWN)
			cleaned_human.wash(CLEAN_SCRUB)
			cleaned_human.regenerate_icons()
			to_chat(cleaned_human, span_danger("[atom_movable] cleans your face!"))

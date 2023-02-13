/datum/storage/organ_box

/datum/storage/organ_box/handle_enter(datum/source, obj/item/arrived)
	. = ..()

	if(!istype(arrived))
		return

	arrived.freeze()

/datum/storage/organ_box/handle_exit(datum/source, obj/item/gone)
	. = ..()

	if(!istype(gone))
		return

	gone.unfreeze()

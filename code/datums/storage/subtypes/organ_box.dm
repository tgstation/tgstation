/datum/storage/organ_box

/datum/storage/organ_box/handle_enter(obj/item/storage/organbox/source, obj/item/arrived)
	. = ..()

	if(!istype(arrived) || !istype(source) || !source.coolant_to_spend())
		return

	arrived.freeze()

/datum/storage/organ_box/handle_exit(datum/source, obj/item/gone)
	. = ..()

	if(!istype(gone))
		return

	gone.unfreeze()

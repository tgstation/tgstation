///Bespoke element for scaling items in hand/inventory and in the overworld (on turfs).
/datum/element/item_scaling
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/overworld_scaling
	var/storage_scaling

///Adds the scaling values set in AddElement to the bespoke element and registers relevant signals.
/datum/element/item_scaling/Attach(datum/target, overworld_scaling, storage_scaling)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	///Initial scaling set to overworld_scaling, being placed in storage should resize to storage_scaling.
	scale(target, overworld_scaling)

	src.overworld_scaling = overworld_scaling
	src.storage_scaling = storage_scaling

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, .proc/scale_storage) //Object added to an inventory/hand slot.
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/scale_overworld) //Object dropped or thrown on a turf.
	RegisterSignal(target, COMSIG_STORAGE_ENTERED, .proc/scale_storage) //Object placed in a storage component.
	RegisterSignal(target, COMSIG_STORAGE_EXITED, .proc/scale_overworld) //Object removed from a storage component.

/datum/element/item_scaling/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED, COMSIG_STORAGE_ENTERED,\
	COMSIG_STORAGE_EXITED))

///Applies a scale transform to an identity matrix and replaces the object's tranform matrix.
/datum/element/item_scaling/proc/scale(datum/source, scaling)
	var/atom/scalable_object = source
	var/matrix/M = matrix()
	scalable_object.transform = M.Scale(scaling)

///Scales the object sprite to overworld_scaling
/datum/element/item_scaling/proc/scale_overworld(datum/source)
	SIGNAL_HANDLER

	scale(source, overworld_scaling)

///Scales the object sprite to storage_scaling
/datum/element/item_scaling/proc/scale_storage(datum/source)
	SIGNAL_HANDLER

	scale(source, storage_scaling)

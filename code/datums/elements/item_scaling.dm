/datum/element/item_scaling
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/overworld_scaling
	var/storage_scaling

/datum/element/item_scaling/Attach(datum/target, overworld_scaling, storage_scaling)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	scale(target, overworld_scaling)

	src.overworld_scaling = overworld_scaling
	src.storage_scaling = storage_scaling

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, .proc/scale_storage)
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/scale_overworld)
	RegisterSignal(target, COMSIG_STORAGE_ENTERED, .proc/scale_storage)
	RegisterSignal(target, COMSIG_STORAGE_EXITED, .proc/scale_overworld)

/datum/element/item_scaling/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED, COMSIG_STORAGE_ENTERED,\
	COMSIG_STORAGE_EXITED))

/datum/element/item_scaling/proc/scale(datum/source, scaling)
	var/atom/scalable_object = source
	var/matrix/M = matrix()
	scalable_object.transform = M.Scale(scaling)

/datum/element/item_scaling/proc/scale_overworld(datum/source)
	SIGNAL_HANDLER

	scale(source, overworld_scaling)

/datum/element/item_scaling/proc/scale_storage(datum/source)
	SIGNAL_HANDLER

	scale(source, storage_scaling)

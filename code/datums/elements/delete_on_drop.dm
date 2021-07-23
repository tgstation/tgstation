/**
 * Attaches to an item, if that item is dropped on the floor delete it
 */
/datum/element/delete_on_drop
	element_flags = ELEMENT_DETACH
	var/list/myvar = list()

/datum/element/delete_on_drop/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_DROPPED, .proc/del_on_drop)

/datum/element/delete_on_drop/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/datum/element/delete_on_drop/proc/del_on_drop(atom/source)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		qdel(source)

/**
 * Attaches to an item, if that item is dropped on the floor delete it
 */
/datum/element/delete_on_drop
	var/list/myvar = list()

/datum/element/delete_on_drop/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_ITEM_DROPPED, COMSIG_CASING_EJECTED), PROC_REF(del_on_drop))

/datum/element/delete_on_drop/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_DROPPED, COMSIG_CASING_EJECTED))

/datum/element/delete_on_drop/proc/del_on_drop(atom/source)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		qdel(source)

/datum/element/trash_if_empty
	var/attach_type = /obj
	var/static/list/update_signals = list(
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_EXITED
	)

/datum/element/trash_if_empty/Attach(datum/source)
	. = ..()
	if(!istype(source, attach_type))
		return ELEMENT_INCOMPATIBLE
	register_signals(source)

/datum/element/trash_if_empty/Detach(datum/source)
	unregister_signals(source)
	REMOVE_TRAIT(source, TRAIT_TRASH_ITEM, ELEMENT_TRAIT(type))
	return ..()

/datum/element/trash_if_empty/proc/register_signals(datum/source)
	RegisterSignals(source, update_signals, PROC_REF(update_trash_trait))

/datum/element/trash_if_empty/proc/unregister_signals(datum/source)
	UnregisterSignal(source, update_signals)

/datum/element/trash_if_empty/proc/update_trash_trait(obj/source)
	SIGNAL_HANDLER
	if(is_empty_or_trash(source))
		ADD_TRAIT(source, TRAIT_TRASH_ITEM, ELEMENT_TRAIT(type))
	else
		REMOVE_TRAIT(source, TRAIT_TRASH_ITEM, ELEMENT_TRAIT(type))

/datum/element/trash_if_empty/proc/is_empty_or_trash(obj/source)
	. = TRUE
	if(!length(source.contents))
		return TRUE
	for(var/obj/item/stored_obj in source.contents)
		if(!QDELING(stored_obj) && !HAS_TRAIT(stored_obj, TRAIT_TRASH_ITEM))
			return FALSE

// Variant for reagent containers
/datum/element/trash_if_empty/reagent_container
	attach_type = /obj/item/reagent_containers
	var/static/list/reagent_signals = list(
		COMSIG_REAGENTS_NEW_REAGENT,
		COMSIG_REAGENTS_ADD_REAGENT,
		COMSIG_REAGENTS_DEL_REAGENT,
		COMSIG_REAGENTS_REM_REAGENT
	)

/datum/element/trash_if_empty/reagent_container/register_signals(obj/item/reagent_containers/source)
	RegisterSignals(source.reagents, reagent_signals, PROC_REF(update_trash_trait))

/datum/element/trash_if_empty/reagent_container/unregister_signals(obj/item/reagent_containers/source)
	UnregisterSignal(source.reagents, reagent_signals)

/datum/element/trash_if_empty/reagent_container/is_empty_or_trash(datum/reagents/source)
	return !source?.total_volume

/// Variant that never considers non-prefilled containers as empty
/datum/element/trash_if_empty/reagent_container/if_prefilled

/datum/element/trash_if_empty/reagent_container/if_prefilled/is_empty_or_trash(datum/reagents/source)
	var/obj/item/reagent_containers/container = source?.my_atom
	if(!container.list_reagents)
		return FALSE
	return ..()

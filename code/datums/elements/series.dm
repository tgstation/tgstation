/**
 * ## series element!
 *
 * bespoke element that assigns a series number to toys on examine, and shows their series name!
 * used for mechas and rare collectable hats, should totally be used for way more ;)
 */
/datum/element/series
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	var/list/subtype_list
	var/series_name

/datum/element/series/Attach(datum/target, subtype, series_name)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(!subtype)
		stack_trace("series element without subtype given!")
		return ELEMENT_INCOMPATIBLE
	subtype_list = subtypesof(subtype)
	src.series_name = series_name
	var/atom/attached = target
	RegisterSignal(attached, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/element/series/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)

///signal called examining
/datum/element/series/proc/on_examine(datum/target, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/series_number = subtype_list.Find(target.type)
	examine_list += span_boldnotice("[target] is part of the \"[series_name]\" series!")
	examine_list += span_notice("Collect them all: [series_number]/[length(subtype_list)].")

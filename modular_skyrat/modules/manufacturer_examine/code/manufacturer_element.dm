/// Element that will tell anyone who examines the parent what company made it
/datum/element/manufacturer_examine
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// String to use for the examine text, use the defines in code/__DEFINES/~skyrat_defines/manufacturer_strings.dm
	var/company_string

/datum/element/manufacturer_examine/Attach(atom/target, given_company_string)
	. = ..()

	if(!istype(target)) // Just in case someone loses it and tries to put this on a datum
		return ELEMENT_INCOMPATIBLE
	if(!given_company_string) // If there's no given string then this element will do absolutely nothing, remove it
		return ELEMENT_INCOMPATIBLE

	src.company_string = given_company_string

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/element/manufacturer_examine/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)

/// Sticks the string given to the element in Attach in the description of the attached target
/datum/element/manufacturer_examine/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += "<br>[company_string]"

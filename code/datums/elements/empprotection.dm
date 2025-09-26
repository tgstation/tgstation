/datum/element/empprotection
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY // Detach for turfs
	argument_hash_start_idx = 2
	var/flags = NONE

/datum/element/empprotection/Attach(datum/target, _flags)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE || !isatom(target))
		return ELEMENT_INCOMPATIBLE
	flags = _flags
	RegisterSignal(target, COMSIG_ATOM_PRE_EMP_ACT, PROC_REF(getEmpFlags))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(get_examine_tags))

/datum/element/empprotection/Detach(atom/target)
	UnregisterSignal(target, list(COMSIG_ATOM_PRE_EMP_ACT, COMSIG_ATOM_EXAMINE_TAGS))
	return ..()

/datum/element/empprotection/proc/getEmpFlags(datum/source, severity)
	SIGNAL_HANDLER

	return flags

/datum/element/empprotection/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(flags)
		examine_list["EMP-proof"] = "It is shielded against electromagnetic pulses."

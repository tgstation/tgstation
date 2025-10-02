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

	return (flags & EMP_PROTECT_ALL)

/datum/element/empprotection/proc/get_examine_tags(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(flags & EMP_NO_EXAMINE)
		return

	if(flags & EMP_PROTECT_ALL == EMP_PROTECT_ALL)
		examine_list["EMP proof"] = "[source.p_They()] [source.p_are()] unaffected by electromagnetic pulses, and shields [source.p_their()] contents and wiring from them."
		return

	if(flags & EMP_PROTECT_SELF)
		examine_list["EMP resilient"] = "[source.p_They()] [source.p_are()] unaffected by electromagnetic pulses."

	if(flags & (EMP_PROTECT_CONTENTS|EMP_PROTECT_WIRES) == (EMP_PROTECT_CONTENTS|EMP_PROTECT_WIRES))
		examine_list["EMP blocking"] = "[source.p_They()] protects [source.p_their()] wiring and contents from electromagnetic pulses."

	else if(flags & EMP_PROTECT_CONTENTS)
		examine_list["EMP blocking"] = "[source.p_They()] protects [source.p_their()] contents from electromagnetic pulses."

	else if(flags & EMP_PROTECT_WIRES)
		examine_list["EMP blocking"] = "[source.p_They()] protects [source.p_their()] wiring from electromagnetic pulses."

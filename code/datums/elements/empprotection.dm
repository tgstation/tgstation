/datum/element/empprotection
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	var/flags = NONE

/datum/element/empprotection/Attach(datum/target, _flags)
	. = ..()
	if(. == ELEMENT_INCOMPATIBLE || !isatom(target))
		return ELEMENT_INCOMPATIBLE
	flags = _flags
	register_signal(target, COMSIG_ATOM_EMP_ACT, .proc/getEmpFlags)

/datum/element/empprotection/Detach(atom/target)
	unregister_signal(target, COMSIG_ATOM_EMP_ACT)
	return ..()

/datum/element/empprotection/proc/getEmpFlags(datum/source, severity)
	SIGNAL_HANDLER

	return flags

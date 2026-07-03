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

	// BANDASTATION EDIT START — перевод тегов
	var/is_female = (source.examine_descriptor() in list("структура", "машина"))
	var/he_she_it = is_female ? "Она" : "Он"
	var/their_low = is_female ? "её" : "его"

	if((flags & EMP_PROTECT_ALL) == EMP_PROTECT_ALL)
		examine_list[is_female ? "полностью ЭМИ-защищённая" : "полностью ЭМИ-защищённый"] = "[he_she_it] не [is_female ? "подвержена" : "подвержен"] воздействию электромагнитных импульсов и защищает [their_low] содержимое и проводку от них."
		return

	if(flags & EMP_PROTECT_SELF)
		examine_list[is_female ? "ЭМИ-устойчивая" : "ЭМИ-устойчивый"] = "[he_she_it] не [is_female ? "подвержена" : "подвержен"] воздействию электромагнитных импульсов."

	if((flags & (EMP_PROTECT_CONTENTS|EMP_PROTECT_WIRES)) == (EMP_PROTECT_CONTENTS|EMP_PROTECT_WIRES))
		examine_list[is_female ? "частично ЭМИ-экранированная" : "частично ЭМИ-экранированный"] = "[he_she_it] защищает [their_low] проводку и содержимое от электромагнитных импульсов."

	else if(flags & EMP_PROTECT_CONTENTS)
		examine_list[is_female ? "частично ЭМИ-экранированная" : "частично ЭМИ-экранированный"] = "[he_she_it] защищает [their_low] содержимое от электромагнитных импульсов."

	else if(flags & EMP_PROTECT_WIRES)
		examine_list[is_female ? "частично ЭМИ-экранированная" : "частично ЭМИ-экранированный"] = "[he_she_it] защищает [their_low] проводку от электромагнитных импульсов."

	// BANDASTATION EDIT END

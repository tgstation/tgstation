/// Makes something look irradiated, but otherwise has no inherent negative effects.
/datum/element/simple_rad

/datum/element/simple_rad/Attach(atom/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_IRRADIATED, type)
	target.rad_glow()
	RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))

/datum/element/simple_rad/Detach(datum/source, ...)
	REMOVE_TRAIT(source, TRAIT_IRRADIATED, type)
	source.remove_filter("rad_glow")
	UnregisterSignal(source, COMSIG_COMPONENT_CLEAN_ACT)
	return ..()

/datum/element/simple_rad/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if(clean_types & CLEAN_TYPE_RADIATION)
		Detach(source)
		return COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP
	return NONE

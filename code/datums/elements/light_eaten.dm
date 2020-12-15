/**
 *
 */
/datum/element/light_eaten
	element_flags = ELEMENT_DETACH

/datum/element/light_eaten/Attach(datum/target)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_UPDATE_LIGHT, .proc/block_light_update)
	return ..()

/datum/element/light_eaten/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_LIGHT)
	return ..()

/// Prevents the atom from ever having positive light
/datum/element/light_eaten/proc/block_light_update(atom/source)
	SIGNAL_HANDLER
	if(source.light_power > 0)
		source.light_power = 0
	if(source.light_range > 0)
		source.light_range = 0
	if(source.light_on)
		source.light_on = FALSE
	return NONE

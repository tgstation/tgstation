/datum/element/rad_insulation
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	var/amount // Multiplier for radiation strength passing through

/datum/element/rad_insulation/Attach(datum/target, _amount=RAD_MEDIUM_INSULATION, protects=TRUE, contamination_proof=TRUE)
	. = ..()
	if(!isatom(target))
		return COMPONENT_INCOMPATIBLE

	if(protects) // Does this protect things in its contents from being affected?
		RegisterSignal(target, COMSIG_ATOM_RAD_PROBE, .proc/rad_probe_react)
	if(contamination_proof) // Can this object be contaminated?
		RegisterSignal(target, COMSIG_ATOM_RAD_CONTAMINATING, .proc/rad_contaminating)
	if(_amount != 1) // If it's 1 it won't have any impact on radiation passing through anyway
		RegisterSignal(target, COMSIG_ATOM_RAD_WAVE_PASSING, .proc/rad_pass)

	amount = _amount

/datum/element/rad_insulation/proc/rad_probe_react(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_RADIATION

/datum/element/rad_insulation/proc/rad_contaminating(datum/source, strength)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_CONTAMINATION

/datum/element/rad_insulation/proc/rad_pass(datum/source, datum/radiation_wave/wave, width)
	SIGNAL_HANDLER

	wave.intensity = wave.intensity*(1-((1-amount)/width)) // The further out the rad wave goes the less it's affected by insulation (larger width)
	return COMPONENT_RAD_WAVE_HANDLED

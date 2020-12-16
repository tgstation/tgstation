// Procs that are re-used by both the light eater component and element to prevent copypasta and duplicate signals

/// Abstracted as a global proc so I can avoid sending the signal from two places and reduce copypasta
/proc/light_eater_table_buffet(atom/commisary, datum/light_eater)
	. = list()
	SEND_SIGNAL(commisary, COMSIG_LIGHT_EATER_QUEUE, ., light_eater)
	for(var/nom in commisary.light_sources)
		var/datum/light_source/morsel = nom
		. += morsel.source_atom

/// Abstracted as a global proc so I can avoid sending the signal from two places and reduce copypasta
/proc/light_eater_devour(atom/light_to_eat, datum/light_eater)
	if(light_to_eat.light_power <= 0 || light_to_eat.light_range <= 0 || !light_to_eat.light_on)
		return FALSE
	if(SEND_SIGNAL(light_to_eat, COMSIG_LIGHT_EATER_ACT, light_eater) & COMPONENT_BLOCK_LIGHT_EATER)
		return FALSE
	return TRUE

/// Abstracted as a global proc so I can reduce copypasta
/proc/light_eater_block_light_update(atom/eaten_light)
	if(eaten_light.light_power <= 0)
		return // Shadowshroom compatible

	eaten_light.light_power = 0
	if(eaten_light.light_range > 0)
		eaten_light.light_range = 0
	if(eaten_light.light_on)
		eaten_light.light_on = FALSE

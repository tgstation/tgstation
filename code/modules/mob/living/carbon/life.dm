#define INHALE_SCALE 5

/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return

/mob/living/carbon/proc/breathe()
	//processing environment chems done here for sake of noncopypastaing
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment.gas_reagents.total_volume)
		//woops, / 0.5 actually equals a multiply...
		environment.gas_reagents.trans_to(src,environment.gas_reagents.total_volume*(BREATH_VOLUME/INHALE_SCALE))

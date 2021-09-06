/**
 * When attached to a basic mob, it gives it the ability to be hurt by gas levels
 */
/datum/element/basic_atmos_sensitive
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///Damage when not fitting atmos requirement
	var/atmos_damage = 1
	///Required atmosphere to not be damaged
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)

/datum/element/basic_atmos_sensitive/Attach(datum/target, atmos_requirements, atmos_damage)
	. = ..()
	if(!isbasicmob(target))
		return ELEMENT_INCOMPATIBLE

	if(atmos_requirements)
		src.atmos_requirements = atmos_requirements
	if(atmos_damage)
		src.atmos_damage = atmos_damage
	RegisterSignal(target, COMSIG_LIVING_LIFE, .proc/on_life)

/datum/element/basic_atmos_sensitive/Detach(datum/source)
	if(source)
		UnregisterSignal(source, COMSIG_LIVING_LIFE)
	return ..()


/datum/element/basic_atmos_sensitive/proc/on_life(datum/target, delta_time, times_fired)
	var/mob/living/basic/basic_mob = target
	var/damaging = FALSE

	if(basic_mob.pulledby?.grab_state >= GRAB_KILL && atmos_requirements["min_oxy"])
		damaging = TRUE //getting choked
	if(isopenturf(basic_mob.loc))
		var/turf/open/current_turf = basic_mob.loc
		if(current_turf.air)
			var/current_gases = current_turf.air.gases
			current_turf.air.assert_gases(arglist(GLOB.hardcoded_gases))
			var/plasma_level = current_gases[/datum/gas/plasma][MOLES]
			var/oxygen_level = current_gases[/datum/gas/oxygen][MOLES]
			var/n2_level = current_gases[/datum/gas/nitrogen][MOLES]
			var/co2_level = current_gases[/datum/gas/carbon_dioxide][MOLES]
			current_turf.air.garbage_collect()
			if(atmos_requirements["min_oxy"] && oxygen_level < atmos_requirements["min_oxy"])
				damaging = TRUE
			else if(atmos_requirements["max_oxy"] && oxygen_level > atmos_requirements["max_oxy"])
				damaging = TRUE
			else if(atmos_requirements["min_plas"] && plasma_level < atmos_requirements["min_plas"])
				damaging = TRUE
			else if(atmos_requirements["max_plas"] && plasma_level > atmos_requirements["max_plas"])
				damaging = TRUE
			else if(atmos_requirements["min_n2"] && n2_level < atmos_requirements["min_n2"])
				damaging = TRUE
			else if(atmos_requirements["max_n2"] && n2_level > atmos_requirements["max_n2"])
				damaging = TRUE
			else if(atmos_requirements["min_co2"] && co2_level < atmos_requirements["min_co2"])
				damaging = TRUE
			else if(atmos_requirements["max_co2"] && co2_level > atmos_requirements["max_co2"])
				damaging = TRUE
		else
			if(atmos_requirements["min_oxy"] || atmos_requirements["min_plas"] || atmos_requirements["min_n2"] || atmos_requirements["min_co2"])
				damaging = TRUE
	if(damaging)
		basic_mob.adjust_health(atmos_damage * delta_time)

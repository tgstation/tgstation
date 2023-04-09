/**
 * ## atmos requirements element!
 *
 * bespoke element that deals damage to the attached mob when the atmos requirements aren't satisfied
 */
/datum/element/atmos_requirements
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// An assoc list of "what atmos does this mob require to survive in".
	var/list/atmos_requirements
	/// How much (brute) damage we take from being in unsuitable atmos.
	var/unsuitable_atmos_damage

/datum/element/atmos_requirements/Attach(datum/target, list/atmos_requirements, unsuitable_atmos_damage = 5)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!atmos_requirements)
		stack_trace("[type] added to [target] without any requirements specified.")
	src.atmos_requirements = atmos_requirements
	src.unsuitable_atmos_damage = unsuitable_atmos_damage
	RegisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING, PROC_REF(on_non_stasis_life))

/datum/element/atmos_requirements/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING)

///signal called by the living mob's life() while non stasis
/datum/element/atmos_requirements/proc/on_non_stasis_life(mob/living/target, delta_time = SSMOBS_DT)
	SIGNAL_HANDLER
	if(is_breathable_atmos(target))
		target.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return
	target.adjustBruteLoss(unsuitable_atmos_damage * delta_time)
	target.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)

/datum/element/atmos_requirements/proc/is_breathable_atmos(mob/living/target)
	if(target.pulledby && target.pulledby.grab_state >= GRAB_KILL && atmos_requirements["min_oxy"])
		return FALSE

	if(!isopenturf(target.loc))
		return TRUE

	var/turf/open/open_turf = target.loc
	if(!open_turf.air && (atmos_requirements["min_oxy"] || atmos_requirements["min_tox"] || atmos_requirements["min_n2"] || atmos_requirements["min_co2"]))
		return FALSE

	var/open_turf_gases = open_turf.air.gases
	open_turf.air.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)

	var/plas = open_turf_gases[/datum/gas/plasma][MOLES]
	var/oxy = open_turf_gases[/datum/gas/oxygen][MOLES]
	var/n2 = open_turf_gases[/datum/gas/nitrogen][MOLES]
	var/co2 = open_turf_gases[/datum/gas/carbon_dioxide][MOLES]

	open_turf.air.garbage_collect()

	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		return FALSE
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		return FALSE
	else if(atmos_requirements["min_plas"] && plas < atmos_requirements["min_plas"])
		return FALSE
	else if(atmos_requirements["max_plas"] && plas > atmos_requirements["max_plas"])
		return FALSE
	else if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		return FALSE
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		return FALSE
	else if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		return FALSE
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		return FALSE

	return TRUE

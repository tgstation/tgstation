/**
 * ## atmos requirements element!
 *
 * bespoke element that deals damage to the attached mob when the atmos requirements aren't satisfied
 */
/datum/element/atmos_requirements
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	argument_hash_end_idx = 3
	/// An assoc list of "what atmos does this mob require to survive in".
	var/list/atmos_requirements
	/// How much (brute) damage we take from being in unsuitable atmos.
	var/unsuitable_atmos_damage

/datum/element/atmos_requirements/Attach(datum/target, list/atmos_requirements, unsuitable_atmos_damage = 5, mapload = FALSE)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(!atmos_requirements)
		CRASH("[type] added to [target] without any requirements specified.")
	var/list/short = atmos_requirements
	if(!short["min_oxy"] && !short["max_oxy"] && !short["min_plas"] && !short["max_plas"] && !short["min_co2"] && !short["max_co2"] && !short["min_n2"] && !short["max_n2"])
		CRASH("[type] added to [target] with all requirements set to 0.")
	src.atmos_requirements = atmos_requirements
	src.unsuitable_atmos_damage = unsuitable_atmos_damage
	RegisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING, PROC_REF(on_non_stasis_life))

	if(!mapload || !PERFORM_ALL_TESTS(focus_only/atmos_and_temp_requirements))
		return
	check_safe_environment(target)

/datum/element/atmos_requirements/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING)

///signal called by the living mob's life() while non stasis
/datum/element/atmos_requirements/proc/on_non_stasis_life(mob/living/target, seconds_per_tick = SSMOBS_DT)
	SIGNAL_HANDLER
	if(is_breathable_atmos(target))
		target.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return
	target.adjustBruteLoss(unsuitable_atmos_damage * seconds_per_tick)
	target.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)

/datum/element/atmos_requirements/proc/is_breathable_atmos(mob/living/target)
	if(target.pulledby && target.pulledby.grab_state >= GRAB_KILL && atmos_requirements["min_oxy"])
		return FALSE

	if(!isopenturf(target.loc))
		return TRUE

	var/can_breathe_vacuum = HAS_TRAIT(target, TRAIT_NO_BREATHLESS_DAMAGE)

	var/min_oxy = can_breathe_vacuum ? 0 : atmos_requirements["min_oxy"]
	var/min_plasma = can_breathe_vacuum ? 0 : atmos_requirements["min_plas"]
	var/min_n2 = can_breathe_vacuum ? 0 : atmos_requirements["min_n2"]
	var/min_co2 = can_breathe_vacuum ? 0 : atmos_requirements["min_co2"]

	var/turf/open/open_turf = target.loc
	if(isnull(open_turf.air))
		if (can_breathe_vacuum)
			return TRUE
		if(min_oxy || min_plasma || min_n2 || min_co2)
			return FALSE
		return TRUE

	var/list/gases = get_atmos_req_list(open_turf)

	if(!ISINRANGE(gases["oxy"], min_oxy, (atmos_requirements["max_oxy"] || INFINITY)))
		return FALSE
	if(!ISINRANGE(gases["plas"], min_plasma, (atmos_requirements["max_plas"] || INFINITY)))
		return FALSE
	if(!ISINRANGE(gases["n2"], min_n2, (atmos_requirements["max_n2"] || INFINITY)))
		return FALSE
	if(!ISINRANGE(gases["co2"], min_co2, (atmos_requirements["max_co2"] || INFINITY)))
		return FALSE
	return TRUE

/datum/element/atmos_requirements/proc/get_atmos_req_list(turf/open/open_turf)
	var/open_turf_gases = open_turf.air.gases
	open_turf.air.assert_gases(/datum/gas/oxygen, /datum/gas/pluoxium, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)

	var/list/return_gases = list()
	return_gases["plas"] = open_turf_gases[/datum/gas/plasma][MOLES]
	return_gases["oxy"] = open_turf_gases[/datum/gas/oxygen][MOLES] + (open_turf_gases[/datum/gas/pluoxium][MOLES] * PLUOXIUM_PROPORTION)
	return_gases["n2"] = open_turf_gases[/datum/gas/nitrogen][MOLES]
	return_gases["co2"] = open_turf_gases[/datum/gas/carbon_dioxide][MOLES]

	open_turf.air.garbage_collect()

	return return_gases

///Ensures that maploaded mobs are in a safe environment. Unit test stuff.
/datum/element/atmos_requirements/proc/check_safe_environment(mob/living/living_mob)
	if(living_mob.stat == DEAD || is_breathable_atmos(living_mob))
		return
	var/turf/open/open_turf = living_mob.loc
	var/list/gases
	var/string_text = "No Air"
	if(open_turf.air)
		gases = get_atmos_req_list(open_turf)
		string_text = "O2: [gases["o2"]] - Plasma: [gases["plasma"]] - N2: [gases["n2"]] - CO2: [gases["co2"]]"
	stack_trace("[living_mob] loaded on a turf with unsafe atmos at \[[open_turf.x], [open_turf.y], [open_turf.z]\] (area : [open_turf.loc]). Turf gases: [string_text]. Check the mob atmos requirements again.")

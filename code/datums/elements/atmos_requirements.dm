	///Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	///Leaving something at 0 means it's off - has no maximum.

	///This damage is taken when atmos doesn't fit all the requirements above.


/**
 * ## atmos requirements element!
 *
 * bespoke element that deals damage to the attached mob when the atmos requirements aren't satisfied
 */
/datum/element/atmos_requirements
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	var/list/atmos_requirements
	var/unsuitable_atmos_damage

/datum/element/atmos_requirements/Attach(datum/target, list/atmos_requirements, unsuitable_atmos_damage)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.atmos_requirements = string_assoc_list(atmos_requirements)
	RegisterSignal(target, COMSIG_LIVING_HANDLE_BREATHING, .proc/on_non_stasis_life)

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
	open_turf.air.assert_gases(arglist(GLOB.hardcoded_gases))

	var/plas = open_turf_gases[/datum/gas/plasma][MOLES]
	var/oxy = open_turf_gases[/datum/gas/oxygen][MOLES]
	var/n2 = open_turf_gases[/datum/gas/nitrogen][MOLES]
	var/co2 = open_turf_gases[/datum/gas/carbon_dioxide][MOLES]

	open_turf.air.garbage_collect()

	. = TRUE
	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		. = FALSE
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		. = FALSE
	else if(atmos_requirements["min_plas"] && plas < atmos_requirements["min_plas"])
		. = FALSE
	else if(atmos_requirements["max_plas"] && plas > atmos_requirements["max_plas"])
		. = FALSE
	else if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		. = FALSE
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		. = FALSE
	else if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		. = FALSE
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		. = FALSE

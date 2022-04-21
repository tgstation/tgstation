SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_BACKGROUND | SS_NO_INIT

	wait = 0.5 SECONDS

	/// A list of radiation sources (/datum/radiation_pulse_information) that have yet to process.
	/// Do not interact with this directly, use `radiation_pulse` instead.
	var/list/datum/radiation_pulse_information/processing = list()

/datum/controller/subsystem/radiation/fire(resumed)
	while (processing.len)
		var/datum/radiation_pulse_information/pulse_information = popleft(processing)

		var/datum/weakref/source_ref = pulse_information.source_ref
		var/atom/source = source_ref.resolve()
		if (isnull(source))
			continue

		pulse(source, pulse_information)

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/radiation/stat_entry(msg)
	msg = "[msg] | Pulses: [processing.len]"
	return ..()

/datum/controller/subsystem/radiation/proc/pulse(atom/source, datum/radiation_pulse_information/pulse_information)
	var/list/cached_rad_insulations = list()

	for (var/atom/movable/target in range(pulse_information.max_range, source))
		if (!can_irradiate_basic(target))
			continue

		var/current_insulation = 1

		for (var/turf/turf_in_between in get_line(source, target) - get_turf(source))
			var/insulation = cached_rad_insulations[turf_in_between]
			if (isnull(insulation))
				insulation = turf_in_between.rad_insulation
				for (var/atom/on_turf as anything in turf_in_between.contents)
					insulation *= on_turf.rad_insulation
				cached_rad_insulations[turf_in_between] = insulation

			current_insulation *= insulation

			if (current_insulation <= pulse_information.threshold)
				break

		SEND_SIGNAL(target, COMSIG_IN_RANGE_OF_IRRADIATION, pulse_information, current_insulation)

		// Check a second time, because of TRAIT_BYPASS_EARLY_IRRADIATED_CHECK
		if (HAS_TRAIT(target, TRAIT_IRRADIATED))
			continue

		if (current_insulation <= pulse_information.threshold)
			continue

		var/irradiation_result = SEND_SIGNAL(target, COMSIG_IN_THRESHOLD_OF_IRRADIATION, pulse_information)
		if (irradiation_result & CANCEL_IRRADIATION)
			continue

		if (pulse_information.minimum_exposure_time && !(irradiation_result & SKIP_MINIMUM_EXPOSURE_TIME_CHECK))
			target.AddComponent(/datum/component/radiation_countdown, pulse_information.minimum_exposure_time)
			continue

		if (!prob(pulse_information.chance))
			continue

		if (irradiate_after_basic_checks(target))
			target.investigate_log("was irradiated by [source].", INVESTIGATE_RADIATION)

/// Will attempt to irradiate the given target, limited through IC means, such as radiation protected clothing.
/datum/controller/subsystem/radiation/proc/irradiate(atom/target)
	if (!can_irradiate_basic(target))
		return FALSE

	irradiate_after_basic_checks()
	return TRUE

/datum/controller/subsystem/radiation/proc/irradiate_after_basic_checks(atom/target)
	PRIVATE_PROC(TRUE)

	if (ishuman(target) && wearing_rad_protected_clothing(target))
		return FALSE

	target.AddComponent(/datum/component/irradiated)
	return TRUE

/// Returns whether or not the target can be irradiated by any means.
/// Does not check for clothing.
/datum/controller/subsystem/radiation/proc/can_irradiate_basic(atom/target)
	if (!CAN_IRRADIATE(target))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_IRRADIATED) && !HAS_TRAIT(target, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK))
		return FALSE

	if (HAS_TRAIT(target, TRAIT_RADIMMUNE))
		return FALSE

	return TRUE

/// Returns whether or not the human is covered head to toe in rad-protected clothing.
/datum/controller/subsystem/radiation/proc/wearing_rad_protected_clothing(mob/living/carbon/human/human)
	for (var/obj/item/bodypart/limb as anything in human.bodyparts)
		var/protected = FALSE

		for (var/obj/item/clothing as anything in human.clothingonpart(limb))
			if (HAS_TRAIT(clothing, TRAIT_RADIATION_PROTECTED_CLOTHING))
				protected = TRUE
				break

		if (!protected)
			return FALSE

	return TRUE

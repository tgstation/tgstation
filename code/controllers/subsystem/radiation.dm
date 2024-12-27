SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_BACKGROUND | SS_NO_INIT

	wait = 0.5 SECONDS

	/// A list of radiation sources (/datum/radiation_pulse_information) that have yet to process.
	/// Do not interact with this directly, use `radiation_pulse` instead.
	var/list/datum/radiation_pulse_information/processing = list()

/datum/controller/subsystem/radiation/fire(resumed)
	while (processing.len)
		var/datum/radiation_pulse_information/pulse_information = processing[1]

		var/datum/weakref/source_ref = pulse_information.source_ref
		var/atom/source = source_ref.resolve()
		if (isnull(source))
			processing.Cut(1, 2)
			continue

		pulse(source, pulse_information)

		if (MC_TICK_CHECK)
			return

		processing.Cut(1, 2)

/datum/controller/subsystem/radiation/stat_entry(msg)
	msg = "[msg] | Pulses: [processing.len]"
	return ..()

/datum/controller/subsystem/radiation/proc/pulse(atom/source, datum/radiation_pulse_information/pulse_information)
	var/list/cached_rad_insulations = list()
	var/list/cached_turfs_to_process = pulse_information.turfs_to_process
	var/turfs_iterated = 0
	for (var/turf/turf_to_irradiate as anything in cached_turfs_to_process)
		turfs_iterated += 1
		for (var/atom/movable/target in turf_to_irradiate)
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

			/// Perceived chance of target getting irradiated.
			var/perceived_chance
			/// Intensity variable which will describe the radiation pulse.
			/// It is used by perceived intensity, which diminishes over range. The chance of the target getting irradiated is determined by perceived_intensity.
			/// Intensity is calculated so that the chance of getting irradiated at half of the max range is the same as the chance parameter.
			var/intensity
			/// Diminishes over range. Used by perceived chance, which is the actual chance to get irradiated.
			var/perceived_intensity

			if(pulse_information.chance < 100) // Prevents log(0) runtime if chance is 100%
				intensity = -log(1 - pulse_information.chance / 100) * (1 + pulse_information.max_range / 2) ** 2
				perceived_intensity = intensity * INVERSE((1 + get_dist_euclidean(source, target)) ** 2) // Diminishes over range.
				perceived_intensity *= (current_insulation - pulse_information.threshold) * INVERSE(1 - pulse_information.threshold) // Perceived intensity decreases as objects that absorb radiation block its trajectory.
				perceived_chance = 100 * (1 - NUM_E ** -perceived_intensity)
			else
				perceived_chance = 100

			var/irradiation_result = SEND_SIGNAL(target, COMSIG_IN_THRESHOLD_OF_IRRADIATION, pulse_information)
			if (irradiation_result & CANCEL_IRRADIATION)
				continue

			if (pulse_information.minimum_exposure_time && !(irradiation_result & SKIP_MINIMUM_EXPOSURE_TIME_CHECK))
				target.AddComponent(/datum/component/radiation_countdown, pulse_information.minimum_exposure_time)
				continue

			if (!prob(perceived_chance))
				continue

			if (irradiate_after_basic_checks(target))
				target.investigate_log("was irradiated by [source].", INVESTIGATE_RADIATION)

		if(MC_TICK_CHECK)
			break

	cached_turfs_to_process.Cut(1, turfs_iterated + 1)

/// Will attempt to irradiate the given target, limited through IC means, such as radiation protected clothing.
/datum/controller/subsystem/radiation/proc/irradiate(atom/target)
	if (!can_irradiate_basic(target))
		return FALSE

	irradiate_after_basic_checks(target)
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

		for (var/obj/item/clothing as anything in human.get_clothing_on_part(limb))
			if (HAS_TRAIT(clothing, TRAIT_RADIATION_PROTECTED_CLOTHING))
				protected = TRUE
				break

		if (!protected)
			return FALSE

	return TRUE

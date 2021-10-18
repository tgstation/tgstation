SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_BACKGROUND

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

/datum/controller/subsystem/radiation/proc/pulse(atom/source, datum/radiation_pulse_information/pulse_information)
	var/list/cached_rad_insulations = list()

	for (var/atom/movable/target in range(pulse_information.max_range, source))
		if (!CAN_IRRADIATE(target))
			continue

		if (HAS_TRAIT(target, TRAIT_IRRADIATED))
			continue

		if (HAS_TRAIT(target, TRAIT_RADIMMUNE))
			continue

		// MOTHBLOCKS TODO: Minimum timer

		var/current_insulation = 1

		for (var/turf/turf_in_between in get_line(source, target))
			var/insulation = cached_rad_insulations[turf_in_between]
			if (isnull(insulation))
				insulation = turf_in_between.rad_insulation
				for (var/atom/on_turf as anything in turf_in_between.contents)
					insulation *= on_turf.rad_insulation
				cached_rad_insulations[turf_in_between] = insulation

			current_insulation *= insulation

			if (current_insulation <= pulse_information.threshold)
				break

		if (current_insulation <= pulse_information.threshold)
			continue

		if (!prob(pulse_information.chance))
			continue

		// MOTHBLOCKS TODO: Rad protected clothes, done through an element that hijacks a signal, or TRAIT_RADIMMUNE

		target.AddComponent(/datum/component/irradiated)

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

		var/datum/weakref/source_ref = pulse_information.source
		var/atom/source = source_ref.resolve()
		if (isnull(source))
			continue

		pulse(source, pulse_information)

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/radiation/proc/pulse(atom/source, datum/radiation_pulse_information/pulse_information)
	// for (var/atom/movable/target in range(pulse_information.max_range, source))
		// if (ishuman(target))


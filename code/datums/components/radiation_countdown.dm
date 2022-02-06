// Should be more than any minimum exposure time coming in
#define TIME_UNTIL_DELETION (10 SECONDS)

/// Begins the countdown before a target can be irradiated.
/// Added by the radiation subsystem when a pulse information has a minimum exposure time.
/// Will clear itself out after a while.
/datum/component/radiation_countdown
	/// The time this component was added
	var/time_added

	/// The shortest minimum time before being irradiated.
	/// If the source has an attempted irradiation again outside this timeframe, it will go through.
	var/minimum_exposure_time

/datum/component/radiation_countdown/Initialize(minimum_exposure_time)
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	src.minimum_exposure_time = minimum_exposure_time

	time_added = world.time

	to_chat(parent, span_userdanger("The air around you feels warm...perhaps you should go somewhere else."))

	start_deletion_timer()

/datum/component/radiation_countdown/proc/start_deletion_timer()
	addtimer(CALLBACK(src, .proc/remove_self), TIME_UNTIL_DELETION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/radiation_countdown/proc/remove_self()
	if (!HAS_TRAIT(parent, TRAIT_IRRADIATED))
		to_chat(parent, span_notice("The air here feels safer."))

	qdel(src)

/datum/component/radiation_countdown/RegisterWithParent()
	RegisterSignal(parent, COMSIG_IN_THRESHOLD_OF_IRRADIATION, .proc/on_pre_potential_irradiation_within_range)

/datum/component/radiation_countdown/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_IN_THRESHOLD_OF_IRRADIATION)

/datum/component/radiation_countdown/proc/on_pre_potential_irradiation_within_range(datum/source, datum/radiation_pulse_information/pulse_information)
	SIGNAL_HANDLER

	minimum_exposure_time = min(minimum_exposure_time, pulse_information.minimum_exposure_time)

	start_deletion_timer()

	// Played with fire, now you might be getting irradiated.
	if (world.time - time_added >= minimum_exposure_time)
		return SKIP_MINIMUM_EXPOSURE_TIME_CHECK

	return CANCEL_IRRADIATION

#undef TIME_UNTIL_DELETION

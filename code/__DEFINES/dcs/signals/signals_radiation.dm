// Radiation signals

/// From the radiation subsystem, called before a potential irradiation.
/// This does not guarantee radiation can reach or will succeed, but merely that there's a radiation source within range.
/// (datum/radiation_pulse_information/pulse_information, insulation_to_target)
#define COMSIG_IN_RANGE_OF_IRRADIATION "in_range_of_irradiation"

/// Fired when the target could be irradiated, right before the chance check is rolled.
/// (datum/radiation_pulse_information/pulse_information)
#define COMSIG_IN_THRESHOLD_OF_IRRADIATION "pre_potential_irradiation_within_range"
	#define CANCEL_IRRADIATION (1 << 0)

	/// If this is flipped, then minimum exposure time will not be checked.
	/// If it is not flipped, and the pulse information has a minimum exposure time, then
	/// the countdown will begin.
	#define SKIP_MINIMUM_EXPOSURE_TIME_CHECK (1 << 1)

/// Fired when scanning something with a geiger counter.
/// (mob/user, obj/item/geiger_counter/geiger_counter)
#define COMSIG_GEIGER_COUNTER_SCAN "geiger_counter_scan"
	/// If not flagged by any handler, will report the subject as being free of irradiation
	#define COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL (1 << 0)

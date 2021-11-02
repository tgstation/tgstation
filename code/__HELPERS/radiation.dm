/// Whether or not it's possible for this atom to be irradiated
#define CAN_IRRADIATE(atom) (ishuman(##atom) || isitem(##atom))

/// Sends out a pulse of radiation, eminating from the source.
/// Radiation is performed by collecting all radiatables within the max range (0 means source only, 1 means adjacent, etc),
/// then makes their way towards them. A number, starting at 1, is multiplied
/// by the insulation amounts of whatever is in the way (for example, walls lowering it down).
/// If this number hits equal or below the threshold, then the target can no longer be irradiated.
/// If the number is above the threshold, then the chance is the chance that the target will be irradiated.
/// As a consumer, this means that max_range going up usually means you want to lower the threshold too,
/// as well as the other way around.
/// If max_range is high, but threshold is too high, then it usually won't reach the source at the max range in time.
/// If max_range is low, but threshold is too low, then it basically guarantees everyone nearby, even if there's walls
/// and such in the way, can be irradiated.
/// You can also pass in a minimum exposure time. If this is set, then this radiation pulse
/// will not irradiate the source unless they have been around *any* radioactive source for that
/// period of time.
/proc/radiation_pulse(
	atom/source,
	max_range,
	threshold,
	chance = DEFAULT_RADIATION_CHANCE,
	minimum_exposure_time = 0,
)
	if(!SSradiation.can_fire)
		return

	var/datum/radiation_pulse_information/pulse_information = new
	pulse_information.source_ref = WEAKREF(source)
	pulse_information.max_range = max_range
	pulse_information.threshold = threshold
	pulse_information.chance = chance
	pulse_information.minimum_exposure_time = minimum_exposure_time

	SSradiation.processing += pulse_information

	return TRUE

/datum/radiation_pulse_information
	var/datum/weakref/source_ref
	var/max_range
	var/threshold
	var/chance
	var/minimum_exposure_time

#define MEDIUM_RADIATION_THRESHOLD_RANGE 0.5
#define EXTREME_RADIATION_CHANCE 30

/// Gets the perceived "danger" of radiation pulse, given the threshold to the target.
/// Returns a RADIATION_DANGER_* define, see [code/__DEFINES/radiation.dm]
/proc/get_perceived_radiation_danger(datum/radiation_pulse_information/pulse_information, insulation_to_target)
	if (insulation_to_target > pulse_information.threshold)
		// We could get irradiated! The only thing stopping us now is chance, so scale based on that.
		if (pulse_information.chance >= EXTREME_RADIATION_CHANCE)
			return PERCEIVED_RADIATION_DANGER_EXTREME
		else
			return PERCEIVED_RADIATION_DANGER_HIGH
	else
		// We're out of the threshold from being irradiated, but by how much?
		if (insulation_to_target / pulse_information.threshold <= MEDIUM_RADIATION_THRESHOLD_RANGE)
			return PERCEIVED_RADIATION_DANGER_MEDIUM
		else
			return PERCEIVED_RADIATION_DANGER_LOW

#undef MEDIUM_RADIATION_THRESHOLD_RANGE
#undef EXTREME_RADIATION_CHANCE

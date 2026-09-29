/// Calculates the max chance for a radiation_pulse via a radioactive reagent
#define CALCULATE_RAD_MAX_CHANCE(rad_power) (20 + (15 * (rad_power - 1)))

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
/// The chance to get irradiated diminishes over range, and from objects that block radiation.
/// Assuming there is nothing in the way, the chance will determine what the chance is to get irradiated from half of max_range.
/// Example: If chance is equal to 30%, and max_range is equal to 8,
/// then the chance for a thing to get irradiated is 30% if they are 4 turfs away from the pulse source.
/proc/radiation_pulse(
	atom/source,
	max_range,
	threshold,
	chance = DEFAULT_RADIATION_CHANCE,
	minimum_exposure_time = 0,
	can_propogate = FALSE,
)
	if(!SSradiation.can_fire)
		return

	var/datum/radiation_pulse_information/pulse_information = new
	pulse_information.source_ref = WEAKREF(source)
	pulse_information.max_range = max_range
	pulse_information.threshold = threshold
	pulse_information.chance = chance
	pulse_information.minimum_exposure_time = minimum_exposure_time
	pulse_information.turfs_to_process = RANGE_TURFS(max_range, source)
	pulse_information.can_propogate = can_propogate

	SSradiation.processing += pulse_information

	return TRUE

/datum/radiation_pulse_information
	var/datum/weakref/source_ref
	var/max_range
	var/threshold
	var/chance
	var/minimum_exposure_time
	var/list/turfs_to_process
	var/can_propogate

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

/// A common proc used to send COMSIG_ATOM_PROPAGATE_RAD_PULSE to adjacent atoms
/// Only used for uranium (false/tram)walls to spread their radiation pulses
/atom/proc/propagate_radiation_pulse()
	for(var/atom/atom in orange(1,src))
		SEND_SIGNAL(atom, COMSIG_ATOM_PROPAGATE_RAD_PULSE, src)

/// Applies relevant radiation effects to the target
/atom/proc/make_irradiated(can_propogate)
	return

/obj/item/make_irradiated(can_propogate)
	AddElement(/datum/element/simple_rad)

/mob/living/carbon/human/make_irradiated(can_propogate)
	apply_status_effect(/datum/status_effect/irradiated, can_propogate)

/// Clears radiation effects from the target
/atom/proc/clear_radiation()
	RemoveElement(/datum/element/simple_rad)

/mob/living/carbon/human/clear_radiation()
	remove_status_effect(/datum/status_effect/irradiated)

/**
 * Heals a bit of toxin damage if the mob is irradiated
 * When the mob has no more toxin damage, the radiation will be cleared.
 *
 * * amount - The amount of toxin damage to heal.
 * * updating_health - Whether to update the mob's health after healing.
 * * required_biotype - The biotype required for the healing to apply.
 * * organ_multiplier - The proc can also be used to heal irradiated organs, determined by this multiplier.
 * Clears radiation from irradiated organs if their damage is fully healed.
 */
/mob/living/carbon/proc/heal_radiation(amount = 1, updating_health = TRUE, required_biotype = NONE, organ_multiplier = 0)
	if(!HAS_TRAIT(src, TRAIT_IRRADIATED))
		return 0

	. = adjust_tox_loss(amount, updating_health = updating_health, required_biotype = required_biotype)
	if(organ_multiplier <= 0)
		return .

	for(var/obj/item/organ/organ as anything in organs)
		if(organ_flags & ORGAN_FAILING)
			continue
		if((required_biotype & MOB_ORGANIC) && !IS_ORGANIC_ORGAN(organ))
			continue
		if((required_biotype & MOB_ROBOTIC) && !IS_ROBOTIC_ORGAN(organ))
			continue
		if((required_biotype & MOB_MINERAL) && !IS_MINERAL_ORGAN(organ))
			continue
		if(!HAS_TRAIT(organ, TRAIT_IRRADIATED))
			continue
		organ.apply_organ_damage(-amount * organ_multiplier)
		if(organ.damage <= 0)
			organ.clear_radiation()

	return .

/// Makes a target glow as if they are irradiated (only visual, last until stopped manually)
/atom/proc/rad_glow(transparency = 1.0)
	var/rad_alpha = 48 * transparency
	add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff14[num2hex(rad_alpha, 2)]", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(rad_grow_loop), rad_alpha), rand(0.1 SECONDS, 1.9 SECONDS), TIMER_DELETE_ME) // Things should look uneven

/// Used to animate the glow effect
/atom/proc/rad_grow_loop(base_alpha)
	PRIVATE_PROC(TRUE)

	var/filter = get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = base_alpha * 2.25, time = 1.5 SECONDS, loop = -1)
	animate(alpha = base_alpha, time = 2.5 SECONDS)

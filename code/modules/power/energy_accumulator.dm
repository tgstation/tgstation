/// The coefficient of the proportionate power output.
/// Doesn't change output total, lower numbers just increases the smoothing - taking longer to ramp up, and longer to drop away.
/// 4% means an accumulator, when starting up for the first time:
/// - emits   50% of what is being received after 40 seconds
/// - emits   90% of what is being received after two minutes
/// - emits   99% of what is being received after four minutes
/// after having stored energy for at least 4-5 minutes, then dropping input to nothing:
/// - emits   50% of what was previously being received after 40 seconds
/// - emits   25% of what was previously being received after 79 seconds
/// - emits   10% of what was previously being received after two minutes
/// - emits    1% of what was previously being received after four minutes
#define ACCUMULATOR_PROPORTIONAL_COEFFICIENT 0.04
/// The coefficient for the constant power output.
#define ACCUMULATOR_CONSTANT_COEFFICIENT 2000

/// Abstract type for generators that accumulate energy over time and slowly release it
/// eg. radiation collectors, tesla coils
/obj/machinery/power/energy_accumulator
	anchored = FALSE
	density = TRUE
	///Whether this accumulator should connect to and power a powernet
	var/wants_powernet = TRUE
	///The amount of energy that is currently inside the machine before being converted to electricity
	var/stored_energy = 0
	///The amount of energy that got processed last tick.
	var/processed_energy = 0

/obj/machinery/power/energy_accumulator/proc/get_stored_joules()
	return stored_energy

/**
 * Gets the energy the energy_accumulator would release within the given timespan time.
 * The power output is proportional to the energy, and has a constant power output added to it.
 * Args:
 * - time: The amount of time that is being processed, in seconds.
 * Returns: The amount of energy it would release in the timespan.
 */
/obj/machinery/power/energy_accumulator/proc/calculate_energy_output(time = 0)
	// dE/dt = -[ACCUMULATOR_PROPORTIONAL_COEFFICIENT] * E - [ACCUMULATOR_CONSTANT_COEFFICIENT]
	return min(stored_energy, stored_energy - ((ACCUMULATOR_PROPORTIONAL_COEFFICIENT * stored_energy + ACCUMULATOR_CONSTANT_COEFFICIENT) * NUM_E ** (-ACCUMULATOR_PROPORTIONAL_COEFFICIENT * time) - ACCUMULATOR_CONSTANT_COEFFICIENT) / ACCUMULATOR_PROPORTIONAL_COEFFICIENT)

/**
 * Calculates the power needed to sustain the energy accumulator at its current energy.
 */
/obj/machinery/power/energy_accumulator/proc/calculate_sustainable_power()
	return ACCUMULATOR_PROPORTIONAL_COEFFICIENT * stored_energy + ACCUMULATOR_CONSTANT_COEFFICIENT

/obj/machinery/power/energy_accumulator/process(seconds_per_tick)
	release_energy(calculate_energy_output(seconds_per_tick))

/**
 * Releases joules amount of its stored energy onto the powernet.
 * Args:
 * - joules: The amount of energy to release.
 * Returns: Whether it successfully released its energy or not.
 */
/obj/machinery/power/energy_accumulator/proc/release_energy(joules = 0)
	if(wants_powernet)
		add_avail(joules)
		stored_energy -= joules
		processed_energy = joules
		return TRUE
	return FALSE

/obj/machinery/power/energy_accumulator/should_have_node()
	return wants_powernet && anchored

/obj/machinery/power/energy_accumulator/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return //no need to process if we didn't change anything.
	if(!wants_powernet)
		return
	if(!anchorvalue)
		disconnect_from_network()
		return
	connect_to_network()

#undef ACCUMULATOR_PROPORTIONAL_COEFFICIENT
#undef ACCUMULATOR_CONSTANT_COEFFICIENT

/// (this*100)% of stored power outputted per tick.
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
#define ACCUMULATOR_STORED_OUTPUT 0.04

/// Abstract type for generators that accumulate energy over time and slowly release it
/// eg. radiation collectors, tesla coils
/obj/machinery/power/energy_accumulator
	anchored = FALSE
	density = TRUE
	///Whether this accumulator should connect to and power a powernet
	var/wants_powernet = TRUE
	///The amount of energy that is currently inside the machine before being converted to electricity
	var/stored_energy = 0

/obj/machinery/power/energy_accumulator/proc/get_stored_joules()
	return energy_to_joules(stored_energy)

/obj/machinery/power/energy_accumulator/proc/get_power_output()
	// Always consume at least 2kJ of energy if we have at least that much stored
	return min(stored_energy, (stored_energy*ACCUMULATOR_STORED_OUTPUT)+joules_to_energy(2000))

/obj/machinery/power/energy_accumulator/process(delta_time)
	// NB: stored_energy is stored in energy units, a unit of measurement which already includes SSmachines.wait
	// Do not multiply by delta_time here. It is already accounted for by being energy units.
	var/power_produced = get_power_output()
	release_energy(power_produced)
	stored_energy -= power_produced

/obj/machinery/power/energy_accumulator/proc/release_energy(power_produced)
	if(wants_powernet)
		add_avail(power_produced)

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

#undef ACCUMULATOR_STORED_OUTPUT

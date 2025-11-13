#define DELAY_BETWEEN_RADIATION_PULSES (3 SECONDS)

/// This atom will regularly pulse radiation.
/datum/element/radioactive
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///Range of our wave in tiles
	var/range
	///Threshold for radioactive permeance
	var/threshold
	///Chance the object is irradiated
	var/chance
	///Minimum time needed in order to be irradiated
	var/minimum_exposure_time
	///How much radiation is given to humans in one pulse
	var/power
	///The most radiation a human can absorb from this source
	var/max_power

	var/list/radioactive_objects = list()

/datum/element/radioactive/New()
	START_PROCESSING(SSdcs, src)

/datum/element/radioactive/Attach(
	datum/target,
	range = 3,
	threshold = RAD_LIGHT_INSULATION,
	chance = URANIUM_IRRADIATION_CHANCE,
	minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	power = 0.5,
	max_power = RAD_STAGE_REQUIREMENTS[3],
	)

	. = ..()

	radioactive_objects[target] = world.time

	src.range = range
	src.threshold = threshold
	src.chance = chance
	src.minimum_exposure_time = minimum_exposure_time
	src.power = power
	src.max_power = max_power

/datum/element/radioactive/Detach(datum/source, ...)
	radioactive_objects -= source

	return ..()

/datum/element/radioactive/process(seconds_per_tick)
	for (var/radioactive_object in radioactive_objects)
		if (world.time - radioactive_objects[radioactive_object] < DELAY_BETWEEN_RADIATION_PULSES)
			continue

		radiation_pulse(
			radioactive_object,
			max_range = range,
			threshold = threshold,
			chance = chance,
			minimum_exposure_time = minimum_exposure_time,
			power = power,
			max_power = max_power
		)

		radioactive_objects[radioactive_object] = world.time

#undef DELAY_BETWEEN_RADIATION_PULSES

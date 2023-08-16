PROCESSING_SUBSYSTEM_DEF(pollution_emitters)
	name = "Pollution Emitters"
	priority = FIRE_PRIORITY_OBJ
	flags = SS_NO_INIT
	wait = 10 SECONDS

/datum/element/pollution_emitter
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// List of all affected atoms
	var/list/affected = list()
	/// Type of the spawned pollutions
	var/pollutant_type
	/// Amount of the pollutants spawned per process
	var/pollutant_amount

/datum/element/pollution_emitter/Attach(datum/target, pollutant_type, pollutant_amount)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.pollutant_type = pollutant_type
	src.pollutant_amount = pollutant_amount
	affected[target] = TRUE

	START_PROCESSING(SSpollution_emitters, src)

/datum/element/pollution_emitter/Detach(datum/target)
	. = ..()

	affected -= target

	if(!affected.len)
		STOP_PROCESSING(SSpollution_emitters, src)

/datum/element/pollution_emitter/process(seconds_per_tick)
	for(var/atom/affected_atom as anything in affected)
		var/turf/my_turf = get_turf(affected_atom)
		my_turf.pollute_turf(pollutant_type, pollutant_amount)

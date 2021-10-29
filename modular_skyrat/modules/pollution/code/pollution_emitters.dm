PROCESSING_SUBSYSTEM_DEF(pollution_emitters)
	name = "Pollution Emitters"
	priority = FIRE_PRIORITY_OBJ
	flags = SS_NO_INIT
	wait = 10 SECONDS

/datum/element/pollution_emitter
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// List of all affected atoms
	var/list/affected = list()
	/// Type of the spawned pollutions
	var/pollutant_type
	/// Amount of the pollutants spawned per process
	var/pollutant_amount

/datum/element/pollution_emitter/New()
	START_PROCESSING(SSpollution_emitters, src)

/datum/element/pollution_emitter/Attach(datum/target, pollutant_type, pollutant_amount)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.pollutant_type = pollutant_type
	src.pollutant_amount = pollutant_amount
	affected[target] = TRUE

/datum/element/pollution_emitter/Detach(datum/target)
	. = ..()
	affected -= target

/datum/element/pollution_emitter/process(delta_time)
	for(var/atom/affected_atom as anything in affected)
		var/turf/my_turf = get_turf(affected_atom)
		my_turf.PolluteTurf(pollutant_type, pollutant_amount)

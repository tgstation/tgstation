#define RAD_DISSIPATE_AMOUNT	0.4

var/datum/subsystem/radiation/SSradiation

/datum/subsystem/radiation
	name = "Radiation"
	priority = -4
	wait = 20
	var/list/processing = list()
	var/list/radiation_sources = list()
	var/irradiate_tick = FALSE

/datum/subsystem/radiation/New()
	NEW_SS_GLOBAL(SSradiation)

/datum/subsystem/radiation/fire()
	if(irradiate_tick)
		irradiate_tick = FALSE
		for(var/V in radiation_sources)
			if(qdeleted(V))
				radiation_sources -= V
				continue
			var/atom/A = V
			A.process_irradiate()
			CHECK_TICK
	else
		irradiate_tick = TRUE

	for(var/V in processing)
		var/turf/T = V
		if(!T.radiation && !T.radiation_induced)
			processing -= T
			continue
		if(T.radiation_induced)
			T.radiation_induced = max(0, T.radiation_induced - RAD_DISSIPATE_AMOUNT)
		if(T.radiation)
			if(T.radiation_ticks_to_remove > 0)
				T.radiation_ticks_to_remove--
			else
				T.radiation = 0
		CHECK_TICK

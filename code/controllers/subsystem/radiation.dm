#define RAD_DISSIPATE_AMOUNT	0.4

var/datum/subsystem/radiation/SSradiation

/datum/subsystem/radiation
	name = "Radiation"
	priority = -4
	wait = 20
	var/list/processing = list()

/datum/subsystem/radiation/New()
	NEW_SS_GLOBAL(SSradiation)

/datum/subsystem/radiation/fire()
	for(var/V in processing)
		var/turf/T = V
		if(T.radiation)
			T.radiation = max(0, T.radiation - RAD_DISSIPATE_AMOUNT)
		else
			processing -= T
		CHECK_TICK

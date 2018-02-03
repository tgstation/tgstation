SUBSYSTEM_DEF(tremors)
	name = "Tremors"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/next_tremor = 0
	var/min_tremor_time = 1200
	var/max_tremor_time = 3000

/datum/controller/subsystem/tremors/fire()
	if(world.time < next_tremor)
		return
	next_tremor = world.time + pick(min_tremor_time, max_tremor_time)
	shake_earth()

/datum/controller/subsystem/tremors/proc/shake_earth()
	var/tremor_type = /datum/weather/tremors
	if(prob(10))
		tremor_type = /datum/weather/tremors/earthquake
	SSweather.run_weather(tremor_type)

/datum/controller/subsystem/tremors/Initialize(start_timeofday)
	next_tremor = world.time + pick(2 * min_tremor_time, 2 * max_tremor_time)
	..()
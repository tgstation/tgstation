#define CYCLE_SUNRISE 	0
#define CYCLE_MORNING 	3000
#define CYCLE_DAYTIME 	6000
#define CYCLE_AFTERNOON 9000
#define CYCLE_SUNSET 	12000 //Deciseconds
#define CYCLE_NIGHTTIME 15000 //5 minutes per day cycle (25 minutes) and 10 minute nighttime
#define CYCLE_END_OF_NIGHT 21000 //Actually just here to signify the start of sunrise
//Help those who see this horrifying code

GLOBAL_LIST_INIT(nightcycle_turfs, typecacheof(list(
	/turf/open/floor/plating/ground)))

SUBSYSTEM_DEF(nightcycle)
	name = "Day/Night Cycle"
	wait = 1
	//var/flags = 0			//see MC.dm in __DEFINES Most flags must be set on world start to take full effect. (You can also restart the mc to force them to process again
	can_fire = TRUE
	var/currentSunPosition
	var/sunColour
	var/sunPower
	var/currentColumn = 1
	var/working = 3
	var/current_tick = 0
	var/newTime
	var/columns_per_iterate = 3 //How many columns to do at a time

/datum/controller/subsystem/nightcycle/fire(resumed = FALSE)
	if (working)
		doWork()
		return
	if (should_new_time())
		working = 1
		currentColumn = 1

/datum/controller/subsystem/nightcycle/proc/should_new_time()

	current_tick++ //10 times a second
	switch (current_tick)
		if (CYCLE_SUNRISE 	to CYCLE_MORNING - 1)
			newTime = "SUNRISE"
		if (CYCLE_MORNING 	to CYCLE_DAYTIME 	- 1)
			newTime = "MORNING"
		if (CYCLE_DAYTIME 	to CYCLE_AFTERNOON	- 1)
			newTime = "DAYTIME"
		if (CYCLE_AFTERNOON to CYCLE_SUNSET 	- 1)
			newTime = "AFTERNOON"
		if (CYCLE_SUNSET 	to CYCLE_NIGHTTIME - 1)
			newTime = "SUNSET"
		if (CYCLE_NIGHTTIME to CYCLE_END_OF_NIGHT - 1)
			newTime = "NIGHTTIME"
		else
			newTime = "SUNRISE"
			current_tick = 0 //Reset the day

	if (newTime != currentSunPosition)
		currentSunPosition = newTime
		updateLight(currentSunPosition)
		. = TRUE
	newTime = null

/datum/controller/subsystem/nightcycle/proc/doWork()

	var/end_x = min(currentColumn + columns_per_iterate, world.maxx) //End of column if we're doing more than one column a time

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/T in block(locate(currentColumn, 1, z), locate(end_x, world.maxy, z)))
			if(T.type in GLOB.nightcycle_turfs)
				T.set_light(2, sunPower, sunColour)

	currentColumn = min(end_x, world.maxx)

	if (currentColumn >= world.maxx)
		currentColumn = 1
		working = 0
		return

/datum/controller/subsystem/nightcycle/proc/updateLight(newTime)
	switch (newTime)
		if ("SUNRISE")
			sunColour = "#ffd1b3"
			sunPower = 0.3
		if ("MORNING")
			sunColour = "#fff2e6"
			sunPower = 0.5
		if ("DAYTIME")
			sunColour = "#FFFFFF"
			sunPower = 0.75
		if ("AFTERNOON")
			sunColour = "#fff2e6"
			sunPower = 0.5
		if ("SUNSET")
			sunColour = "#ffcccc"
			sunPower = 0.3
		if("NIGHTTIME")
			sunColour = "#00111a"
			sunPower = 0.20

#undef CYCLE_SUNRISE
#undef CYCLE_MORNING
#undef CYCLE_DAYTIME
#undef CYCLE_AFTERNOON
#undef CYCLE_SUNSET
#undef CYCLE_NIGHTTIME

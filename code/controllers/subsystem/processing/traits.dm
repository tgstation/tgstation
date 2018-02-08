//Used to process and handle roundstart trait datums
//Due to their nature, roundstart traits are objects, but are otherwise tied to the normal trait system
PROCESSING_SUBSYSTEM_DEF(traits)
	name = "Traits"
	init_order = INIT_ORDER_TRAITS
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME

	var/list/traits = list()		//Assoc. list of all roundstart trait datums; "name" = /path/
	var/list/trait_points = list()	//Assoc. list of trait names and their "point cost"; positive numbers are good traits, and negative ones are bad
	var/list/trait_objects = list()	//A list of all trait objects in the game, since some may process

/datum/controller/subsystem/processing/traits/Initialize(timeofday)
	if(!traits.len)
		SetupTraits()
	..()

/datum/controller/subsystem/processing/traits/proc/SetupTraits()
	for(var/V in subtypesof(/datum/trait))
		var/datum/trait/T = V
		traits[initial(T.name)] = T
		trait_points[initial(T.name)] = initial(T.value)

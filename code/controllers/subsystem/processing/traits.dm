//Used to process and handle roundstart trait datums
//Trait datums are separate from trait strings:
// - Trait strings are used for faster checking in code
// - Trait datums are stored and hold different effects, as well as being a vector for applying trait string
PROCESSING_SUBSYSTEM_DEF(traits)
	name = "Traits"
	init_order = INIT_ORDER_TRAITS
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME

	var/list/traits = list()		//Assoc. list of all roundstart trait datum types; "name" = /path/
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

/datum/controller/subsystem/processing/traits/proc/AssignTraits(mob/living/user, client/cli, spawn_effects)
	GenerateTraits(cli)
	if(user && cli && cli.prefs.character_traits)
		for(var/V in cli.prefs.character_traits)
			user.add_trait_datum(V, spawn_effects)

/datum/controller/subsystem/processing/traits/proc/GenerateTraits(client/user)
	if(user && user.prefs && user.prefs.character_traits)
		if(user.prefs.character_traits.len)
			return
		user.prefs.character_traits = user.prefs.all_traits

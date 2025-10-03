/// The subsystem used to tick [/datum/ai_movement] instances. Handling the movement of individual AI instances
MOVEMENT_SUBSYSTEM_DEF(ai_movement)
	name = "AI movement"
	flags = SS_BACKGROUND|SS_TICKER
	priority = FIRE_PRIORITY_NPC_MOVEMENT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	///an assoc list of all ai_movement types. Assoc type to instance
	var/list/movement_types

/datum/controller/subsystem/movement/ai_movement/Initialize()
	SetupAIMovementInstances()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/movement/ai_movement/proc/SetupAIMovementInstances()
	movement_types = list()
	for(var/key in subtypesof(/datum/ai_movement))
		var/datum/ai_movement/ai_movement = new key
		movement_types[key] = ai_movement

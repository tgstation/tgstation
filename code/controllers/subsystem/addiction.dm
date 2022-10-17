/*!
This subsystem mostly exists to populate and manage the withdrawal singletons.
*/

SUBSYSTEM_DEF(addiction)
	name = "Addiction"
	flags = SS_NO_FIRE
	///Dictionary of addiction.type || addiction ref
	var/list/all_addictions = list()

/datum/controller/subsystem/addiction/Initialize()
	InitializeAddictions()
	return SS_INIT_SUCCESS

///Ran on initialize, populates the addiction dictionary
/datum/controller/subsystem/addiction/proc/InitializeAddictions()
	for(var/type in subtypesof(/datum/addiction))
		var/datum/addiction/ref = new type
		all_addictions[type] = ref

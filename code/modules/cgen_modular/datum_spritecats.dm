/*
	Hello & welcome to modular_spritecats.dm.
	Due to the default setup, modularizing /tg/station's sprite_accessories & DNA systems is a necessity to cleanly add new species.
	This is tied into code/__HELPERS/global_lists, code/_globalvars/lists/flavor_misc, and a couple others.

	If you're joining me however many years down the line from early 2023, welcome to the madness that is SS13 development.
	Good luck. - CliffracerX/Naaka Ko
*/

GLOBAL_LIST_EMPTY(mutant_spritecat_list)

/datum/mutant_spritecat
	//the name this category belongs to
	var/name
	//a unique identifier for coders, distinct from pretty names when needed
	var/id
	//a pointer to the sprite accessory type that'll be initialized
	var/sprite_acc
	//the default state, used for consistent human dummies augbdfaugahfg
	var/default = "None"

	//this is the proc that should call anything necessary for setting up the category while getting around BYOND jank
	//yes i am naming it init_jank, this is the spess experience at its finest
	proc/init_jank()
		//world.log << "Initializing sprite category [name]"

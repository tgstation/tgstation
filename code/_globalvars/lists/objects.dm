GLOBAL_LIST_INIT(cable_list, list())					//Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_LIST_INIT(portals, list())					//list of all /obj/effect/portal
GLOBAL_LIST_INIT(airlocks, list())					//list of all airlocks
GLOBAL_LIST_INIT(mechas_list, list())				//list of all mechs. Used by hostile mobs target tracking.
GLOBAL_LIST_INIT(shuttle_caller_list, list())  		//list of all communication consoles and AIs, for automatic shuttle calls when there are none.
GLOBAL_LIST_INIT(machines, list())					//NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
GLOBAL_LIST_INIT(syndicate_shuttle_boards, list())	//important to keep track of for managing nukeops war declarations.
GLOBAL_LIST_INIT(navbeacons, list())					//list of all bot nagivation beacons, used for patrolling.
GLOBAL_LIST_INIT(teleportbeacons, list())			//list of all tracking beacons used by teleporters
GLOBAL_LIST_INIT(deliverybeacons, list())			//list of all MULEbot delivery beacons.
GLOBAL_LIST_INIT(deliverybeacontags, list())			//list of all tags associated with delivery beacons.
GLOBAL_LIST_INIT(nuke_list, list())
GLOBAL_LIST_INIT(alarmdisplay, list())				//list of all machines or programs that can display station alerts
GLOBAL_LIST_INIT(singularities, list())				//list of all singularities on the station (actually technically all engines)

GLOBAL_LIST(chemical_reactions_list)				//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_INIT(materials_list, list())				//list of all /datum/material datums indexed by material id.
GLOBAL_LIST_INIT(tech_list, list())					//list of all /datum/tech datums indexed by id.
GLOBAL_LIST_INIT(surgeries_list, list())				//list of all surgeries by name, associated with their path.
GLOBAL_LIST_INIT(crafting_recipes, list())				//list of all table craft recipes
GLOBAL_LIST_INIT(rcd_list, list())					//list of Rapid Construction Devices.
GLOBAL_LIST_INIT(apcs_list, list())					//list of all Area Power Controller machines, seperate from machines for powernet speeeeeeed.
GLOBAL_LIST_INIT(tracked_implants, list())			//list of all current implants that are tracked to work out what sort of trek everyone is on. Sadly not on lavaworld not implemented...
GLOBAL_LIST_INIT(tracked_chem_implants, list())			//list of implants the prisoner console can track and send inject commands too
GLOBAL_LIST_INIT(poi_list, list())					//list of points of interest for observe/follow
GLOBAL_LIST_INIT(pinpointer_list, list())			//list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_LIST_INIT(zombie_infection_list, list()) 		// A list of all zombie_infection organs, for any mass "animation"
GLOBAL_LIST_INIT(meteor_list, list())				// List of all meteors.
GLOBAL_LIST_INIT(active_jammers, list())             // List of active radio jammers

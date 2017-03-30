GLOBAL_EMPTY_LIST(cable_list)					//Index for all cables, so that powernets don't have to look through the entire world all the time
GLOBAL_EMPTY_LIST(portals)					//list of all /obj/effect/portal
GLOBAL_EMPTY_LIST(airlocks)					//list of all airlocks
GLOBAL_EMPTY_LIST(mechas_list)				//list of all mechs. Used by hostile mobs target tracking.
GLOBAL_EMPTY_LIST(shuttle_caller_list)  		//list of all communication consoles and AIs, for automatic shuttle calls when there are none.
GLOBAL_EMPTY_LIST(machines)					//NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
GLOBAL_EMPTY_LIST(syndicate_shuttle_boards)	//important to keep track of for managing nukeops war declarations.
GLOBAL_EMPTY_LIST(navbeacons)					//list of all bot nagivation beacons, used for patrolling.
GLOBAL_EMPTY_LIST(teleportbeacons)			//list of all tracking beacons used by teleporters
GLOBAL_EMPTY_LIST(deliverybeacons)			//list of all MULEbot delivery beacons.
GLOBAL_EMPTY_LIST(deliverybeacontags)			//list of all tags associated with delivery beacons.
GLOBAL_EMPTY_LIST(nuke_list)
GLOBAL_EMPTY_LIST(alarmdisplay)				//list of all machines or programs that can display station alerts
GLOBAL_EMPTY_LIST(singularities)				//list of all singularities on the station (actually technically all engines)

GLOBAL_LIST(chemical_reactions_list)				//list of all /datum/chemical_reaction datums. Used during chemical reactions
GLOBAL_LIST(chemical_reagents_list)				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_EMPTY_LIST(materials_list)				//list of all /datum/material datums indexed by material id.
GLOBAL_EMPTY_LIST(tech_list)					//list of all /datum/tech datums indexed by id.
GLOBAL_EMPTY_LIST(surgeries_list)				//list of all surgeries by name, associated with their path.
GLOBAL_EMPTY_LIST(crafting_recipes)				//list of all table craft recipes
GLOBAL_EMPTY_LIST(rcd_list)					//list of Rapid Construction Devices.
GLOBAL_EMPTY_LIST(apcs_list)					//list of all Area Power Controller machines, seperate from machines for powernet speeeeeeed.
GLOBAL_EMPTY_LIST(tracked_implants)			//list of all current implants that are tracked to work out what sort of trek everyone is on. Sadly not on lavaworld not implemented...
GLOBAL_EMPTY_LIST(tracked_chem_implants)			//list of implants the prisoner console can track and send inject commands too
GLOBAL_EMPTY_LIST(poi_list)					//list of points of interest for observe/follow
GLOBAL_EMPTY_LIST(pinpointer_list)			//list of all pinpointers. Used to change stuff they are pointing to all at once.
GLOBAL_EMPTY_LIST(zombie_infection_list) 		// A list of all zombie_infection organs, for any mass "animation"
GLOBAL_EMPTY_LIST(meteor_list)				// List of all meteors.
GLOBAL_EMPTY_LIST(active_jammers)             // List of active radio jammers

GLOBAL_EMPTY_LIST(wire_color_directory)
GLOBAL_EMPTY_LIST(wire_name_directory)
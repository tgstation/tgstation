var/global/list/cable_list = list()					//Index for all cables, so that powernets don't have to look through the entire world all the time
var/global/list/portals = list()					//list of all /obj/effect/portal
var/global/list/airlocks = list()					//list of all airlocks
var/global/list/mechas_list = list()				//list of all mechs. Used by hostile mobs target tracking.
var/global/list/shuttle_caller_list = list()  		//list of all communication consoles and AIs, for automatic shuttle calls when there are none.
var/global/list/machines = list()					//NOTE: this is a list of ALL machines now. The processing machines list is SSmachine.processing !
var/global/list/navbeacons = list()					//list of all bot nagivation beacons, used for patrolling.
var/global/list/deliverybeacons = list()			//list of all MULEbot delivery beacons.
var/global/list/deliverybeacontags = list()			//list of all tags associated with delivery beacons.

var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/surgeries_list = list()				//list of all surgeries by name, associated with their path.
var/global/list/table_recipes = list()				//list of all table craft recipes
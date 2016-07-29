<<<<<<< HEAD
//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, hair_styles_list, hair_styles_male_list, hair_styles_female_list)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, facial_hair_styles_list, facial_hair_styles_male_list, facial_hair_styles_female_list)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, underwear_list, underwear_m, underwear_f)
	//undershirt
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, undershirt_list, undershirt_m, undershirt_f)
	//socks
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, socks_list)
	//lizard bodyparts (blizzard intensifies)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, body_markings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, tails_list_lizard)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated/lizard, animated_tails_list_lizard)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, tails_list_human)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails_animated/human, animated_tails_list_human)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, snouts_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, horns_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, ears_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, wings_open_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, frills_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines_animated, animated_spines_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, r_wings_list,roundstart = TRUE)


	//Species
	for(var/spath in subtypesof(/datum/species))
		var/datum/species/S = new spath()
		if(S.roundstart)
			roundstart_species[S.id] = S.type
		species_list[S.id] = S.type

	//Surgeries
	for(var/path in subtypesof(/datum/surgery))
		surgeries_list += new path()

	//Materials
	for(var/path in subtypesof(/datum/material))
		var/datum/material/D = new path()
		materials_list[D.id] = D

	//Techs
	for(var/path in subtypesof(/datum/tech))
		var/datum/tech/D = new path()
		tech_list[D.id] = D

	init_subtypes(/datum/crafting_recipe, crafting_recipes)

/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()

	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	world << .
*/

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in subtypesof(prototype))
			L+= path
		return L
=======
var/list/clients = list()							//list of all clients
var/list/admins = list()							//list of all clients whom are admins
var/list/directory = list()							//list of all ckeys with associated client

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/list/mixed_modes = list()							//Set when admins wish to force specific modes to be mixed

var/global/list/player_list = list()				//List of all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//List of all mobs, including clientless
var/global/list/living_mob_list = list()			//List of all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/dead_mob_list = list()				//List of all dead mobs, including clientless. Excludes /mob/new_player
var/list/observers = new/list()
var/global/list/areas = list()
var/global/list/turfs = list()

var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
var/global/list/landmarks_list = list()				//list of all landmarks created
var/global/list/surgery_steps = list()				//list of all surgery steps  |BS12
var/global/list/mechas_list = list()				//list of all mechs. Used by hostile mobs target tracking.

// Posters
var/global/list/datum/poster/poster_designs = typesof(/datum/poster) - /datum/poster - /datum/poster/goldstar

//Preferences stuff
	//Underwear
var/global/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "Mankini", "Love-Hearts", "Black2", "Grey2", "Stripey", "Kinky", "None") //Curse whoever made male/female underwear diffrent colours
var/global/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "Thong", "Babydoll", "Baby-Blue", "Green", "Pink", "Kinky", "None")
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel", "Satchel Alt")

// This is stupid as fuck.
var/list/hit_appends = list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF")

//*-hud user lists
var/global/list/table_recipes = list() //list of all table craft recipes
var/global/list/med_hud_users = list() //list of all entities using a medical HUD.
var/global/list/sec_hud_users = list() //list of all entities using a security HUD.

//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	var/list/paths
	//Surgery Steps - Initialize all /datum/surgery_step into a list
	paths = typesof(/datum/surgery_step)-/datum/surgery_step
	for(var/T in paths)
		var/datum/surgery_step/S = new T
		surgery_steps += S
	sort_surgeries()


/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()


	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	to_chat(world, .)
*/

var/global/list/escape_list = list()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

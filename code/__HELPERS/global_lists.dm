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
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, legs_list)
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

	//Emotes
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		emote_list[E.key] = E

	init_subtypes(/datum/crafting_recipe, crafting_recipes)

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

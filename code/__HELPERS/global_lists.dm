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
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, socks_list, socks_m, socks_f)

	//Species
	for(var/spath in typesof(/datum/species))
		if(spath == /datum/species)
			continue
		var/datum/species/S = new spath()
		if(S.roundstart)
			roundstart_species[S.name] = S.type
		species_list[S.id] = S.type

	//Surgeries
	for(var/path in typesof(/datum/surgery))
		if(path == /datum/surgery)
			continue
		var/datum/surgery/S = new path()
		surgeries_list[S.name] = S

	init_subtypes(/datum/table_recipe, table_recipes)

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
	if(!istype(L))	L = list()
	for(var/path in typesof(prototype))
		if(path == prototype)	continue
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in typesof(prototype))
			if(path == prototype)
				continue
			L+= path
		return L

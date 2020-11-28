/proc/random_features()
	/*if(!GLOB.tails_list_human.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human)
	if(!GLOB.tails_list_lizard.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard)
	if(!GLOB.snouts_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list)
	if(!GLOB.horns_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, GLOB.horns_list)
	if(!GLOB.ears_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.horns_list)
	if(!GLOB.frills_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list)
	if(!GLOB.spines_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list)
	if(!GLOB.legs_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list)
	if(!GLOB.body_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings_list)
	if(!GLOB.wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	if(!GLOB.moth_wings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list)
	if(!GLOB.moth_markings_list.len)
		init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_markings, GLOB.moth_markings_list)*/
	//For now we will always return none for tail_human and ears.
	return MANDATORY_FEATURE_LIST

/proc/accessory_list_of_key_for_species(key, datum/species/S)
	var/list/accessory_list = list()
	for(var/name in GLOB.sprite_accessories[key])
		var/datum/sprite_accessory/SP = GLOB.sprite_accessories[key][name]
		if(SP.recommended_species && !(S.id in SP.recommended_species))
			continue
		accessory_list += SP.name
	return accessory_list


/proc/random_accessory_of_key_for_species(key, datum/species/S)
	var/list/accessory_list = accessory_list_of_key_for_species(key, S)
	var/datum/sprite_accessory/SP = GLOB.sprite_accessories[key][pick(accessory_list)]
	if(!SP)
		CRASH("Cant find random accessory of [key] key, for species [S.id]")
	return SP

/proc/random_unique_vox_name(attempts_to_find_unique_name=10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(vox_name())

		if(!findname(.))
			break

/proc/assemble_body_markings_from_set(datum/body_marking_set/BMS, list/features, datum/species/pref_species)
	var/list/body_markings = list()
	for(var/set_name in BMS.body_marking_list)
		var/datum/body_marking/BM = GLOB.body_markings[set_name]
		for(var/zone in GLOB.body_markings_per_limb)
			var/list/marking_list = GLOB.body_markings_per_limb[zone]
			if(set_name in marking_list)
				if(!body_markings[zone])
					body_markings[zone] = list()
				body_markings[zone][set_name] = BM.get_default_color(features, pref_species)
	return body_markings

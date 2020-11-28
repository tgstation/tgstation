/datum/species/mammal
	name = "Anthromorph" //Called so because the species is so much more universal than just mammals
	id = "mammal"
	default_color = "4B4B4B"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "horns" = "None", "ears" = ACC_RANDOM, "legs" = ACC_RANDOM, "taur" = "None", "wings" = "None")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	liked_food = GROSS | MEAT | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/mammal_parts_greyscale.dmi'

/datum/species/mammal/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/third_color
	var/random = rand(1,7)
	switch(random)
		if(1)
			main_color = "FFF"
			second_color = "333"
			third_color = "333"
		if(2)
			main_color = "FFD"
			second_color = "D61"
			third_color = "A52"
		if(3)
			main_color = "D61"
			second_color = "FFF"
			third_color = "D61"
		if(4)
			main_color = "CCC"
			second_color = "FFF"
			third_color = "FFF"
		if(5)
			main_color = "A52"
			second_color = "C83"
			third_color = "FFF"
		if(6)
			main_color = "FFD"
			second_color = "FEC"
			third_color = "FDB"
		if(7) //Oh no you've rolled the sparkle dog
			main_color = random_short_color()
			second_color = random_short_color()
			third_color = random_short_color()
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = third_color
	return returned

/datum/species/mammal/get_random_body_markings(list/passed_features)
	var/name = "None"
	var/list/candidates = GLOB.body_marking_sets.Copy()
	for(var/candi in candidates)
		var/datum/body_marking_set/setter = GLOB.body_marking_sets[candi]
		if(setter.recommended_species && !(id in setter.recommended_species))
			candidates -= candi
	if(length(candidates))
		name = pick(candidates)
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

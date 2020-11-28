/datum/species/akula
	name = "Akula"
	id = "akula"
	default_color = "4B4B4B"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "ears" = ACC_RANDOM, "legs" = "Normal Legs")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	liked_food = GROSS | MEAT | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/akula_parts_greyscale.dmi'

/datum/species/akula/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of sharkish colors, with a whiter secondary and tertiary
	switch(random)
		if(1)
			main_color = "689"
			second_color = "BCD"
		if(2)
			main_color = "345"
			second_color = "DDE"
		if(3)
			main_color = "456"
			second_color = "DDE"
		if(4)
			main_color = "665"
			second_color = "DDE"
		if(5)
			main_color = "444"
			second_color = "DDE"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/akula/get_random_body_markings(list/passed_features)
	var/name = "Shark"
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

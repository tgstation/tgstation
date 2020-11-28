/datum/species/tajaran
	name = "Tajaran"
	id = "tajaran"
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
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/mammal_parts_greyscale.dmi'
	limbs_id = "mammal"

/datum/species/tajaran/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of mostly coldish, animal, matching colors
	switch(random)
		if(1)
			main_color = "BA8"
			second_color = "AA9"
		if(2)
			main_color = "776"
			second_color = "887"
		if(3)
			main_color = "A98"
			second_color = "AA9"
		if(4)
			main_color = "EED"
			second_color = "FEE"
		if(5)
			main_color = "DC9"
			second_color = "DCA"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

/datum/species/tajaran/get_random_body_markings(list/passed_features)
	var/name = pick("Tajaran", "Floof", "Floofer")
	var/datum/body_marking_set/BMS = GLOB.body_marking_sets[name]
	var/list/markings = list()
	if(BMS)
		markings = assemble_body_markings_from_set(BMS, passed_features, src)
	return markings

/datum/species/tajaran/random_name(gender,unique,lastname)
	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male_taj)
	else
		randname = pick(GLOB.first_names_female_taj)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names_taj)]"

	return randname

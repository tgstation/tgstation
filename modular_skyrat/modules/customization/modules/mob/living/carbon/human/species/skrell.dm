/datum/species/skrell
	name = "Skrell"
	id = "skrell"
	default_color = "4B4B4B"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("skrell_hair" = ACC_RANDOM)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'modular_skyrat/modules/customization/icons/mob/species/skrell_parts_greyscale.dmi'
	eyes_icon = 'modular_skyrat/modules/customization/icons/mob/species/skrell_eyes.dmi'

/datum/species/skrell/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/random = rand(1,6)
	//Choose from a range of green-blue colors
	switch(random)
		if(1)
			main_color = "4F7"
		if(2)
			main_color = "2F8"
		if(3)
			main_color = "2FB"
		if(4)
			main_color = "2FF"
		if(5)
			main_color = "2BF"
		if(6)
			main_color = "26F"
	returned["mcolor"] = main_color
	returned["mcolor2"] = main_color
	returned["mcolor3"] = main_color
	return returned

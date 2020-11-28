/datum/species/unathi
	name = "Unathi"
	id = "unathi"
	default_color = "4B4B4B"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "spines" = "None", "frills" = "None", "horns" = ACC_RANDOM, "body_markings" = ACC_RANDOM, "legs" = "Normal Legs")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	liked_food = GROSS | MEAT | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_id = "lizard"

/datum/species/unathi/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/second_color
	var/random = rand(1,5)
	//Choose from a variety of green or brown colors, with a darker secondary and tertiary
	switch(random)
		if(1)
			main_color = "1C0"
			second_color = "180"
		if(2)
			main_color = "5C1"
			second_color = "5A1"
		if(3)
			main_color = "7A1"
			second_color = "681"
		if(4)
			main_color = "862"
			second_color = "741"
		if(5)
			main_color = "3B1"
			second_color = "391"
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = second_color
	return returned

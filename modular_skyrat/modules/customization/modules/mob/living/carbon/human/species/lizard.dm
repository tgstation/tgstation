/datum/species/lizard
	mutant_bodyparts = list()
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "spines" = ACC_RANDOM, "frills" = ACC_RANDOM, "horns" = ACC_RANDOM, "body_markings" = ACC_RANDOM, "legs" = "Digitigrade Legs", "taur" = "None", "wings" = "None")

/datum/species/lizard/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color = random_short_color()
	var/second_color
	var/third_color
	var/random = rand(1,3)
	switch(random)
		if(1) //First random case - all is the same
			second_color = main_color
			third_color = main_color
		if(2) //Second case, derrivatory shades, except there's no helpers for that and I dont feel like writing them
			second_color = main_color
			third_color = main_color
		if(3) //Third case, more randomisation
			second_color = random_short_color()
			third_color = random_short_color()
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = third_color
	return returned

/datum/species/lizard/ashwalker
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,NO_UNDERWEAR)

////////////////////
/////BODYPARTS/////
////////////////////

/datum/species
	var/static/screenicon = new /datum/sprite_accessory/screen

/obj/item/bodypart/var/should_draw_hippie = FALSE

/mob/living/carbon/proc/draw_hippie_parts(undo = FALSE)
	if(!undo)
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_hippie = TRUE
	else
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_hippie = FALSE

/datum/species/proc/hippie_mutant_bodyparts(bodypart, mob/living/carbon/human/H)
	switch(bodypart)
		if("moth_wings")
			return GLOB.moth_wings_list[H.dna.features["moth_wings"]]
		if("screen")
			return screenicon
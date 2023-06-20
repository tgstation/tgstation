/*
	Hello & welcome to datum_newmutant.dm.
	Due to the default setup, modularizing /tg/station's sprite_accessories & DNA systems is a necessity to cleanly add new species.
	This is tied into preference classes (e.g, lizard species features) and code/modules/mob/living/carbon/human/species.dm to add arbitrary renderers for new mutant parts.

	If you're joining me however many years down the line from early 2023, welcome to the madness that is SS13 development.
	Good luck. - CliffracerX/Naaka Ko
*/

/datum/mutant_newmutantpart
	//the name of this new bodypart for pretty-printing if needed
	var/name
	//a unique identifier for coders, distinct from pretty names when needed
	var/id

	//this is the proc that should call anything necessary for setting up the category while getting around BYOND jank
	proc/get_accessory(var/bodypart, var/source)
		//will be in form of:
		//if(bodypart == "the thing")
		//	return GLOB.appropriate_list[source.dna.features["some_feature_id"]]
		//else
		//	return null
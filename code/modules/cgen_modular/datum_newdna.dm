/*
	Hello & welcome to modular_newdna.dm.
	Due to the default setup, modularizing /tg/station's sprite_accessories & DNA systems is a necessity to cleanly add new species.
	This is tied primarily into code/datums/dna.dm; as most features ARE stored in your DNA, which is both super cool, and a complete pain in my arse.

	If you're joining me however many years down the line from early 2023, welcome to the madness that is SS13 development.
	Good luck. - CliffracerX/Naaka Ko
*/

/datum/mutant_newdnafeature
	//the name of this new feature for pretty-printing if needed
	var/name
	//a unique identifier for coders, distinct from pretty names when needed
	var/id

	//this is the proc that should call anything necessary for setting up the category while getting around BYOND jank
	proc/gen_unique_features(var/features, var/L)
		//will be in form of:
		//if(features["feature_id"])
		//	L[APPLICABLE_DNA_BLOCK] = construct_block(GLOB.applicable_list.Find(features["feature_id"]), GLOB.applicable_list.len)

	proc/update_appear(var/datum/dna/dna, var/features)
		//will be in the form of:
		//if(dna.features["feature_id"])
		//	dna.features["feature_id"] = GLOB.applicable_list[deconstruct_block(get_uni_feature_block(features, APPLICABLE_DNA_BLOCK), GLOB.applicable_list.len)]
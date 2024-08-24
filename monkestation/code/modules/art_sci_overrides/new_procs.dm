/proc/random_rgb_pairlists(list/red_pairs, list/green_pairs, list/blue_pairs, list/alpha_pairs)
	if(!length(red_pairs) || !length(blue_pairs) || !length(green_pairs) || !length(alpha_pairs))
		return COLOR_CULT_RED

	if(!length(red_pairs) >= 2)
		red_pairs[2] = 255
	if(!length(blue_pairs) >= 2)
		blue_pairs[2] = 255
	if(!length(green_pairs) >= 2)
		green_pairs[2] = 255
	if(!length(alpha_pairs) >= 2)
		alpha_pairs[2] = 255

	var/red = rand(red_pairs[1], red_pairs[2])
	var/green = rand(green_pairs[1], green_pairs[2])
	var/blue = rand(blue_pairs[1], blue_pairs[2])
	var/alpha = rand(alpha_pairs[1], alpha_pairs[2])

	return rgb(red, green, blue, alpha)


/proc/spawn_artifact(turf/loc, forced_origin)
	if (!loc)
		return
	if(!length(GLOB.artifact_effect_rarity))
		build_weighted_rarities()

	var/obj/structure/artifact/A = new(loc,forced_origin)
	return A


/proc/build_weighted_rarities()
	GLOB.artifact_effect_rarity["all"] = list() ///this needs to be created first for indexing sake
	for(var/datum/artifact_origin/origin as anything in subtypesof(/datum/artifact_origin))
		GLOB.artifact_effect_rarity[initial(origin.type_name)] = list()

	for(var/datum/artifact_effect/artifact_effect as anything in subtypesof(/datum/artifact_effect))
		var/weight = initial(artifact_effect.weight)
		if(!weight)
			continue
		GLOB.artifact_effect_rarity["all"][artifact_effect] = weight
		for(var/origin in GLOB.artifact_effect_rarity)
			if(origin in initial(artifact_effect.valid_origins))
				GLOB.artifact_effect_rarity[origin][artifact_effect] = weight

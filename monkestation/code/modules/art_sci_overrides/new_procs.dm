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
	if(!length(GLOB.artifact_rarity))
		build_weighted_rarities()

	var/list/weighted_list

	if(forced_origin)
		weighted_list = GLOB.artifact_rarity[forced_origin]
	else
		weighted_list = GLOB.artifact_rarity["all"]

	var/datum/component/artifact/picked  = pick_weight(weighted_list)
	var/type = initial(picked.associated_object)
	return new type(loc)


/proc/build_weighted_rarities()
	GLOB.artifact_rarity["all"] = list() ///this needs to be created first for indexing sake
	for(var/datum/artifact_origin/origin as anything in subtypesof(/datum/artifact_origin))
		GLOB.artifact_rarity[initial(origin.type_name)] = list()

	for(var/datum/component/artifact/artifact_type as anything in subtypesof(/datum/component/artifact))
		var/weight = initial(artifact_type.weight)
		if(!weight)
			continue
		GLOB.artifact_rarity["all"][artifact_type] = weight
		for(var/origin in GLOB.artifact_rarity)
			if(origin in initial(artifact_type.valid_origins))
				GLOB.artifact_rarity[origin][artifact_type] = weight

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

	var/list/weighted_list
	if(forced_origin)
		weighted_list = SSartifacts.artifact_rarities[forced_origin]
	else
		weighted_list = SSartifacts.artifact_rarities["all"]

	var/datum/component/artifact/picked  = pick_weight(weighted_list)
	var/type = initial(picked.associated_object)
	return new type(loc)

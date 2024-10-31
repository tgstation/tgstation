///How many times did we survive being a cripple?
/datum/award/score/hardcore_random
	name = "Hardcore random points"
	desc = "Well, I might be a blind, deaf, crippled guy, but hey, at least I'm alive."
	database_id = HARDCORE_RANDOM_SCORE

///How many maintenance pills did you eat?
/datum/award/score/maintenance_pill
	name = "Maintenance Pills Consumed"
	desc = "Wait why?"
	database_id = MAINTENANCE_PILL_SCORE

///How high of a score on the Intento did we get?
/datum/award/score/intento_score
	name = "Intento Score"
	desc = "A blast from the future?"
	database_id = INTENTO_SCORE

/// What's the highest amount of style points we've gotten?
/datum/award/score/style_score
	name = "Style Score"
	desc = "You might not be a robot, but you were damn close."
	database_id = STYLE_SCORE

/datum/award/score/progress/fish
	name = "Fish Species Caught"
	desc = "How many different species of fish you've caught so far. Gotta fish 'em all."
	table_id = "fish_progress"
	database_id = FISH_SCORE

/datum/award/score/progress/fish/validate_entries(list/entries, list/validated_entries)
	. = ..()
	for(var/fish_id in validated_entries)
		if(!(SSfishing.catchable_fish[fish_id]))
			validated_entries -= fish_id
			. = FALSE

/datum/award/score/progress/fish/get_progress(datum/achievement_data/holder)
	var/list/data = list(
		"name" = "Fishdex",
		"percent" = 0,
		"value_text" = "Subsystems still initializing...",
		"entries" = list(),
	)
	if(!SSfishing.initialized)
		return data
	var/list/catched_fish = holder.data[type]
	var/catched_len = length(catched_fish)
	var/catchable_len = length(SSfishing.catchable_fish)
	data["percent"] = catched_len/catchable_len
	data["value_text"] = "[catched_len] / [catchable_len]"
	var/index = 1
	var/max_zeros = round(log(10, catchable_len))
	for(var/fish_id in SSfishing.catchable_fish)
		var/obj/item/fish/fish = SSfishing.catchable_fish[fish_id]
		var/catched = (fish_id in catched_fish)
		var/entry_name = "◦[prefix_zeros_to_number(index, max_zeros)]◦ [catched ? full_capitalize(initial(fish.name)) : "??????" ]"
		var/list/icon_dimensions = get_icon_dimensions(initial(fish.icon))
		data["entries"] += list(list(
			"name" = entry_name,
			"icon" = catched ? SSfishing.cached_fish_icons[fish] : SSfishing.cached_unknown_fish_icons[fish],
			"height" = icon_dimensions["height"] * 2,
			"width" = icon_dimensions["width"] * 2,
		))
		index++
	return data

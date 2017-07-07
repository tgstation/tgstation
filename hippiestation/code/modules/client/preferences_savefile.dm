/datum/preferences/proc/hippie_character_pref_load(savefile/S)
	//moths
	S["feature_moth_wings"] >> features["moth_wings"]
	features["moth_wings"] 	= sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list)
	//gear loadout
	var/text_to_load
	S["loadout"] >> text_to_load
	var/list/saved_loadout_paths = splittext(text_to_load, "|")
	for(var/i in saved_loadout_paths)
		var/datum/gear/path = text2path(i)
		if(path)
			LAZYADD(chosen_gear, path)
			gear_points -= initial(path.cost)

/datum/preferences/proc/hippie_character_pref_save(savefile/S)
	//moths
	S["feature_moth_wings"] << features["moth_wings"]
	//gear loadout
	if(islist(chosen_gear))
		if(chosen_gear.len)
			var/text_to_save = chosen_gear.Join("|")
			S["loadout"] << text_to_save
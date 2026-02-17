/datum/unit_test/missing_icons
	abstract_type = /datum/unit_test/missing_icons
	var/list/possible_icon_states = list()
	var/default_location = "icons/"
	/// additional_icon_locations is for downstream modularity support for finding missing sprites in additonal DMI file locations.
	/// Make sure these locations are also present in tools/deploy.sh
	var/additional_icon_locations

/datum/unit_test/missing_icons/proc/generate_possible_icon_states_list(directory_path)
	if(!directory_path)
		directory_path = default_location
	for(var/file_path in flist(directory_path))
		if(findtext(file_path, ".dmi"))
			for(var/sprite_icon in icon_states("[directory_path][file_path]", 1)) //2nd arg = 1 enables 64x64+ icon support, otherwise you'll end up with "sword0_1" instead of "sword"
				possible_icon_states[sprite_icon] += list("[directory_path][file_path]")
		else
			possible_icon_states += generate_possible_icon_states_list("[directory_path][file_path]")

/datum/unit_test/missing_icons/proc/compile_icon_state_locations()
	generate_possible_icon_states_list(default_location)
	for(var/path in additional_icon_locations)
		generate_possible_icon_states_list(path)

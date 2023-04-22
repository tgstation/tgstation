/// Makes sure objects actually have icons that exist!
/datum/unit_test/missing_icons
	var/static/list/possible_icon_states = list()
	/// additional_icon_location is for downstream modularity support.
	/// Make sure this location is also present in tools/deploy.sh
	/// If you need additional paths ontop of this second one, you can add another generate_possible_icon_states_list("your/folder/path/") below the if(additional_icon_location) block in Run(), and make sure to add that path to tools/deploy.sh as well.
	var/additional_icon_location = null

/datum/unit_test/missing_icons/proc/generate_possible_icon_states_list(directory_path)
	if(!directory_path)
		directory_path = "icons/obj/"
	for(var/file_path in flist(directory_path))
		if(findtext(file_path, ".dmi"))
			for(var/sprite_icon in icon_states("[directory_path][file_path]", 1)) //2nd arg = 1 enables 64x64+ icon support, otherwise you'll end up with "sword0_1" instead of "sword"
				possible_icon_states[sprite_icon] += list("[directory_path][file_path]")
		else
			possible_icon_states += generate_possible_icon_states_list("[directory_path][file_path]")

/datum/unit_test/missing_icons/Run()
	generate_possible_icon_states_list()
	generate_possible_icon_states_list("icons/effects/")
	if(additional_icon_location)
		generate_possible_icon_states_list(additional_icon_location)

	//Add EVEN MORE paths if needed here!
	//generate_possible_icon_states_list("your/folder/path/")
	var/list/bad_list = list()
	for(var/obj/obj_path as anything in subtypesof(/obj))
		if(ispath(obj_path, /obj/item))
			var/obj/item/item_path = obj_path
			if(initial(item_path.item_flags) & ABSTRACT)
				continue

		if(initial(obj_path.greyscale_colors) && initial(obj_path.greyscale_config)) //GAGS has its own unit test.
			continue

		var/icon = initial(obj_path.icon)
		if(isnull(icon))
			continue
		var/icon_state = initial(obj_path.icon_state)
		if(isnull(icon_state))
			continue

		if(length(bad_list) && (icon_state in bad_list[icon]))
			continue

		if(icon_exists(icon, icon_state))
			continue

		bad_list[icon] += list(icon_state)

		var/match_message
		if(icon_state in possible_icon_states)
			for(var/file_place in possible_icon_states[icon_state])
				match_message += (match_message ? " & '[file_place]'" : " - Matching sprite found in: '[file_place]'")

		TEST_FAIL("Missing icon_state for [obj_path] in '[icon]'.\n\ticon_state = \"[icon_state]\"[match_message]")


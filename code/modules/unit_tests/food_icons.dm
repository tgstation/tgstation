/// Makes sure food items actually have icons that exist!
/datum/unit_test/missing_food_icons
	var/static/list/possible_icon_states = list()
	/// additional_food_location is for downstream modularity support.
	/// Make sure this location is also present in tools/deploy.sh
	/// If you need additional paths ontop of this second one, you can add another generate_possible_icon_states_list("your/folder/path/food/") below the if(additional_food_location) block in Run(), and make sure to add that path to tools/deploy.sh as well.
	var/additional_food_location = null

/datum/unit_test/missing_food_icons/proc/generate_possible_icon_states_list(directory_path)
	if(!directory_path)
		directory_path = "icons/obj/food/"
	for(var/file_path in flist(directory_path))
		if(findtext(file_path, ".dmi"))
			for(var/sprite_icon in icon_states("[directory_path][file_path]", 1)) //2nd arg = 1 enables 64x64+ icon support, otherwise you'll end up with "sword0_1" instead of "sword"
				possible_icon_states[sprite_icon] += list("[directory_path][file_path]")
		else
			possible_icon_states += generate_possible_icon_states_list("[directory_path][file_path]")

/datum/unit_test/missing_food_icons/Run()
	generate_possible_icon_states_list()
	if(additional_food_location)
		generate_possible_icon_states_list(additional_food_location)

	//Add EVEN MORE paths if needed here!
	//generate_possible_icon_states_list("your/folder/path/food/")

	for(var/obj/item/food/item_path as anything in subtypesof(/obj/item/food))
		if(initial(item_path.item_flags) & ABSTRACT)
			continue


		var/icon = initial(item_path.icon)
		if(isnull(icon))
			continue
		var/icon_state = initial(item_path.icon_state)
		if(isnull(icon_state))
			continue

		if(icon_exists(icon, icon_state))
			continue

		var/match_message = (icon_state in possible_icon_states) ? TRUE : null
		if(match_message)
			match_message = null
			for(var/file_place in possible_icon_states[icon_state])
				match_message += (match_message ? " & '[file_place]'" : " - Matching sprite found in: '[file_place]'")

		TEST_FAIL("Missing icon_state for [item_path] in '[icon]'.\n\ticon_state = \"[icon_state]\"[match_message]")


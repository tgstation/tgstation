/// Makes sure objects actually have icons that exist!
/datum/unit_test/missing_icons/icon_state
	default_location = "icons/obj/"

/datum/unit_test/missing_icons/icon_state/compile_icon_state_locations()
	. = ..()
	generate_possible_icon_states_list("icons/effects/")

/datum/unit_test/missing_icons/icon_state/Run()
	compile_icon_state_locations()

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


/// Makes sure items with defined inhand_icon_states... actually have icons that exist!
/datum/unit_test/missing_icons/inhand_icon_state
	default_location = "icons/mob/inhands/"
	var/fallback_log_message
	var/unset_inhand_var_message

/datum/unit_test/missing_icons/inhand_icon_state/Run()
	compile_icon_state_locations()

	for(var/obj/item/item_path as anything in subtypesof(/obj/item))
		if(initial(item_path.item_flags) & ABSTRACT)
			continue

		var/skip_left
		var/skip_right
		if(initial(item_path.greyscale_colors)) //greyscale stuff has its own unit test.
			skip_left = initial(item_path.greyscale_config_inhand_left)
			skip_right = initial(item_path.greyscale_config_inhand_right)
			if(skip_left && skip_right)
				continue

		var/lefthand_file = initial(item_path.lefthand_file)
		var/righthand_file = initial(item_path.righthand_file)

		var/held_icon_state = initial(item_path.inhand_icon_state)
		if(!held_icon_state)
			var/base_icon_state = initial(item_path.icon_state)
			if(!isnull(base_icon_state) && lefthand_file && righthand_file) //Suggest inhand icons that match with the icon_state var.
				var/missing_var_message
				if(base_icon_state in possible_icon_states)
					for(var/file_place in possible_icon_states[base_icon_state])
						missing_var_message += (missing_var_message ? " & '[file_place]'" : " - Possible matching sprites for \"[base_icon_state]\" found in: '[file_place]'")
					unset_inhand_var_message += "\n\t[item_path] does not have an inhand_icon_state value[missing_var_message]"
			continue

		var/match_message
		if(held_icon_state in possible_icon_states)
			for(var/file_place in possible_icon_states[held_icon_state])
				match_message += (match_message ? " & '[file_place]'" : " - Matching sprite found in: '[file_place]'")

		if(!(skip_left || skip_right) && !lefthand_file && !righthand_file)
			TEST_FAIL("Missing both icon files for [item_path].\n\tinhand_icon_state = \"[held_icon_state]\"[match_message]")
			continue

		var/missing_left
		var/left_fallback
		if(!skip_left)
			if(!lefthand_file)
				TEST_FAIL("Missing left inhand icon file for [item_path].\n\tinhand_icon_state = \"[held_icon_state]\"[match_message]")
			else
				missing_left = !icon_exists(lefthand_file, held_icon_state)
				if(missing_left && icon_exists(lefthand_file, ""))
					left_fallback = TRUE

		var/missing_right
		var/right_fallback
		if(!skip_right)
			if(!righthand_file)
				TEST_FAIL("Missing right inhand icon file for [item_path].\n\tinhand_icon_state = \"[held_icon_state]\"[match_message]")
			else
				missing_right = !icon_exists(righthand_file, held_icon_state)
				if(missing_right && icon_exists(righthand_file, ""))
					right_fallback = TRUE

		if(missing_right && missing_left)
			if(!match_message && right_fallback && left_fallback)
				fallback_log_message += "\n\t[item_path] has invalid value, using fallback icon.\n\tinhand_icon_state = \"[held_icon_state]\""
				continue
			TEST_FAIL("Missing inhand sprites for [item_path] in both '[lefthand_file]' & '[righthand_file]'.\n\tinhand_icon_state = \"[held_icon_state]\"[match_message]")
		else if(missing_left)
			TEST_FAIL("Missing left inhand sprite for [item_path] in '[lefthand_file]'[left_fallback ? ", using fallback icon" : null].\n\tinhand_icon_state = \"[held_icon_state]\"[match_message]")
		else if(missing_right)
			TEST_FAIL("Missing right inhand sprite for [item_path] in '[righthand_file]'[right_fallback ? ", using fallback icon" : null].\n\tinhand_icon_state = \"[held_icon_state]\"[match_message]")

	if(fallback_log_message)
		TEST_FAIL("Invalid inhand_icon_state values should be set to null if there isn't a valid icon.[fallback_log_message]")

	if(unset_inhand_var_message)
		log_test("\tNotice - Possible inhand icon matches found. It is best to be explicit with inhand sprite values.[unset_inhand_var_message]")


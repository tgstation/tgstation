/// Makes sure objects actually have icons that exist!
/datum/unit_test/missing_icons/onfloor
	default_location = "icons/obj/"

/datum/unit_test/missing_icons/onfloor/Run()
	compile_icon_state_locations()

	var/list/bad_list = list()
	for(var/obj/item/item_path as anything in valid_subtypesof(/obj/item))
		if(item_path::item_flags & ABSTRACT)
			continue

		if(item_path::greyscale_colors && item_path::greyscale_config) //GAGS has its own unit test.
			continue

		var/icon = item_path::onflooricon
		if(isnull(icon))
			continue
		var/icon_state = item_path::onflooricon_state || item_path::icon_state
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

		TEST_FAIL("Missing onflooricon_state for [item_path] in '[icon]'.\n\ticon_state or onfloorcion_state = \"[icon_state]\"[match_message]")

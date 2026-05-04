/// Makes sure suit slot items aren't using CS:S fallbacks.
/datum/unit_test/missing_icons/worn_icons
	default_location = "icons/mob/clothing/"

/datum/unit_test/missing_icons/worn_icons/Run()
	compile_icon_state_locations()

	var/list/already_warned_icons = list()

	for(var/obj/item/item_path as anything in (subtypesof(/obj/item) - typesof(/obj/item/mod)))
		var/cached_slot_flags = initial(item_path.slot_flags)
		if(!cached_slot_flags || (cached_slot_flags & ITEM_SLOT_LPOCKET) || (cached_slot_flags & ITEM_SLOT_RPOCKET) || initial(item_path.item_flags) & ABSTRACT)
			continue


		if(initial(item_path.greyscale_colors) && initial(item_path.greyscale_config_worn)) //GAGS has its own unit test.
			continue

		var/worn_icon = initial(item_path.worn_icon) //override icon file. where our sprite is contained if set. (ie modularity stuff)
		var/worn_icon_state = initial(item_path.worn_icon_state) //overrides icon_state.
		var/icon_state = worn_icon_state || initial(item_path.icon_state) //icon_state. what sprite name we are looking for.


		if(isnull(icon_state))
			continue //no sprite for the item.
		if(icon_state in already_warned_icons)
			continue

		var/match_message
		if(icon_state in possible_icon_states)
			for(var/file_place in possible_icon_states[icon_state])
				match_message += (match_message ? " & '[file_place]'" : " - Matching sprite found in: '[file_place]'")

		if(worn_icon) //easiest to check since we override everything. this automatically includes downstream support.
			if(isnull(worn_icon_state)) // no worn sprite for this item.
				continue
			if(!(icon_state in icon_states(worn_icon, 1)))
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in worn_icon override file, '[worn_icon]'[match_message]")
			continue

		var/icon_file //checks against all the default icon locations if one isn't defined.
		if(cached_slot_flags & ITEM_SLOT_BACK)
			icon_file = 'icons/mob/clothing/back.dmi'

			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_ID)
			icon_file = 'icons/mob/clothing/id.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_GLOVES)
			icon_file = 'icons/mob/clothing/hands.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_EYES)
			icon_file = 'icons/mob/clothing/eyes.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_EARS)
			icon_file = 'icons/mob/clothing/ears.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_NECK)
			icon_file = 'icons/mob/clothing/neck.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_MASK)
			icon_file = 'icons/mob/clothing/mask.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

		if(cached_slot_flags & ITEM_SLOT_BELT)
			icon_file = 'icons/mob/clothing/belt.dmi'
			if(!(icon_state in icon_states(icon_file, 1)))
				already_warned_icons += icon_state
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in '[icon_file]'[match_message]")

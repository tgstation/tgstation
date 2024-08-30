/// Makes sure suit slot items aren't using CS:S fallbacks.
/datum/unit_test/suit_storage_icons
	///These types need to be done, but it's been years so lets just grandfather them in until we get sprites made.
	var/list/explicit_types_to_ignore = list(
	)

/datum/unit_test/suit_storage_icons/Run()
	var/list/wearable_item_paths = list()

	for(var/obj/item/item_path as anything in subtypesof(/obj/item))
		var/cached_slot_flags = initial(item_path.slot_flags)
		if(!(cached_slot_flags & ITEM_SLOT_SUITSTORE) || (initial(item_path.item_flags) & ABSTRACT))
			continue
		wearable_item_paths |= item_path

	for(var/obj/item/clothing/clothing_path in (subtypesof(/obj/item/clothing) - typesof(/obj/item/clothing/head/mob_holder) - typesof(/obj/item/clothing/suit/space/santa))) //mob_holder is a psuedo abstract item. santa suit is a VERY SNOWFLAKE admin spawn suit that can hold /every/ possible item.
		for(var/path in clothing_path::allowed) //find all usable suit storage stuff.
			wearable_item_paths |= path

	for(var/datum/mod_theme/mod_theme as anything in GLOB.mod_themes)
		mod_theme = GLOB.mod_themes[mod_theme]
		wearable_item_paths |= mod_theme.allowed_suit_storage

	for(var/obj/item/item_path as anything in typecacheof(wearable_item_paths))
		if(initial(item_path.item_flags) & ABSTRACT)
			continue
		if(item_path in explicit_types_to_ignore) //Temporarily disabled checking on these paths.
			continue

		var/worn_icon = initial(item_path.worn_icon) //override icon file. where our sprite is contained if set. (ie modularity stuff)
		var/worn_icon_state = initial(item_path.worn_icon_state) //overrides icon_state.
		var/icon_state = worn_icon_state || initial(item_path.icon_state) //icon_state. what sprite name we are looking for.


		if(isnull(icon_state))
			continue //no sprite for the item.

		if(worn_icon) //easiest to check since we override everything.
			if(!(icon_state in icon_states(worn_icon)))
				TEST_FAIL("[item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in worn_icon override file, '[worn_icon]'")
			continue

		if(!(icon_state in icon_states('icons/mob/clothing/belt_mirror.dmi')))
			var/has_belt_icon = (icon_state in icon_states('icons/mob/clothing/belt.dmi'))
			TEST_FAIL("[item_path] using a missing texture placeholder due to invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\"[has_belt_icon ? ". Has a valid normal belt icon." : null]")

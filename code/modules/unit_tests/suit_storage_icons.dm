/// Makes sure suit slot items aren't using CS:S fallbacks.
/datum/unit_test/suit_storage_icons

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

	var/list/already_warned_icons = list()
	var/count = 1 //to be removed once the test goes live / into CI failure mode.
	for(var/obj/item/item_path as anything in typecacheof(wearable_item_paths))
		if(initial(item_path.item_flags) & ABSTRACT)
			continue

		var/worn_icon = initial(item_path.worn_icon) //override icon file. where our sprite is contained if set. (ie modularity stuff)
		var/worn_icon_state = initial(item_path.worn_icon_state) //overrides icon_state.
		var/icon_state = worn_icon_state || initial(item_path.icon_state) //icon_state. what sprite name we are looking for.


		if(isnull(icon_state))
			continue //no sprite for the item.
		if(icon_state in already_warned_icons)
			continue

		if(worn_icon) //easiest to check since we override everything.
			if(!icon_exists(worn_icon, icon_state))
				log_test("\t[count] - [item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\" in worn_icon override file, '[worn_icon]'")
				count++
			continue

		if(!icon_exists('icons/mob/clothing/belt_mirror.dmi', icon_state))
			already_warned_icons += icon_state
			log_test("\t[count] - [item_path] using invalid [worn_icon_state ? "worn_icon_state" : "icon_state"], \"[icon_state]\"")
			count++

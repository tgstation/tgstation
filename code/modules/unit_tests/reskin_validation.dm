/datum/unit_test/reskin_validation

/datum/unit_test/reskin_validation/Run()
	var/list/known_names = list()
	for(var/atom_skin_path, atom_skin in get_atom_skins())
		var/datum/atom_skin/skin = atom_skin

		if(isnull(skin::preview_name))
			TEST_FAIL("Reskin [skin] is missing a preview_name.")
		// preview names are bundled by abstract types
		else if(known_names["[skin.preview_name]-[skin.abstract_type]"])
			TEST_FAIL("Reskin [skin] has a duplicate preview_name [skin.preview_name].")
		else
			known_names["[skin.preview_name]-[skin.abstract_type]"] = TRUE

		if(skin.new_icon && skin.new_icon_state && !icon_exists(skin.new_icon, skin.new_icon_state))
			TEST_FAIL("Reskin [skin] has a new_icon_state [skin.new_icon_state] that does not exist in file [skin.new_icon].")

		var/atom/greyscale_item_path = skin.greyscale_item_path
		var/datum/greyscale_config/greyscale_config = skin.greyscale_config
		var/greyscale_colors = skin.greyscale_colors
		var/field_count = 0
		if(greyscale_item_path) // If any of these are set, they should all be set
			field_count++
		if(greyscale_config)
			field_count++
		if(greyscale_colors)
			field_count++
		if(!field_count)
			continue
		if(field_count != 3)
			TEST_FAIL("[skin]: incomplete greyscale definition: item_path: [greyscale_item_path], \
			config: [greyscale_config], \
			colors: [greyscale_colors]")

		if(isnull(greyscale_item_path::greyscale_config) || isnull(greyscale_item_path::greyscale_colors))
			TEST_FAIL("[skin]: greyscale_item_path is set to an item that does not have a greyscale config or greyscale_colors set! \
				Either set those up for the item, or set all the greyscale fields on the skin to null.")

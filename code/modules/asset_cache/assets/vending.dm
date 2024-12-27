/datum/asset/spritesheet/vending
	name = "vending"

/datum/asset/spritesheet/vending/create_spritesheets()
	// initialising the list of items we need
	var/target_items = list()
	for(var/obj/machinery/vending/vendor as anything in typesof(/obj/machinery/vending))
		vendor = new vendor() // It seems `initial(list var)` has nothing. need to make a type.
		target_items |= vendor.products
		target_items |= vendor.premium
		target_items |= vendor.contraband
		qdel(vendor)

	// building icons for each item
	for (var/atom/item as anything in target_items)
		if (!ispath(item, /atom))
			continue

		var/icon_file
		var/icon_state = initial(item.icon_state)
		var/icon_color = initial(item.color)
		// GAGS icons must be pregenerated
		if(initial(item.greyscale_config) && initial(item.greyscale_colors))
			icon_file = SSgreyscale.GetColoredIconByType(initial(item.greyscale_config), initial(item.greyscale_colors))
		// Colored atoms must be pregenerated
		else if(icon_color && icon_state)
			icon_file = initial(item.icon)
		// Otherwise we can rely on DMIcon, so skip it to save init time
		else
			continue

		if (PERFORM_ALL_TESTS(focus_only/invalid_vending_machine_icon_states))
			var/icon_states_list = icon_states(icon_file)
			if (!(icon_state in icon_states_list))
				var/icon_states_string
				for (var/an_icon_state in icon_states_list)
					if (!icon_states_string)
						icon_states_string = "[json_encode(an_icon_state)]([text_ref(an_icon_state)])"
					else
						icon_states_string += ", [json_encode(an_icon_state)]([text_ref(an_icon_state)])"

				stack_trace("[item] does not have a valid icon state, icon=[icon_file], icon_state=[json_encode(icon_state)]([text_ref(icon_state)]), icon_states=[icon_states_string]")
				continue

		var/icon/produced = icon(icon_file, icon_state, SOUTH)
		if (!isnull(icon_color) && icon_color != COLOR_WHITE)
			produced.Blend(icon_color, ICON_MULTIPLY)

		var/imgid = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")

		Insert(imgid, produced)

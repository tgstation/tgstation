/obj/item/clothing
	/// Needs to follow this syntax: either a list() with the x and y coordinates of the pixel you want to get the colour from, or a hexcolour. Colour one replaces red, two replaces blue, and three replaces green in the icon state.
	var/list/species_clothing_colors[3]
	/// Needs to be a RGB-greyscale format icon state in all species' clothing icon files.
	var/species_clothing_icon_state
	// Skyrat edit addition end

/obj/item/clothing/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
    if(atom_integrity <= 0 && damage_flag == FIRE) // Our clothes don't get destroyed by fire, shut up stack trace >:(
        return

    return ..()

// Generates a coloured species-specific variant of the clothing item
/obj/item/clothing/proc/generate_species_clothing(file_to_use, state_to_use, species) 
	var/icon/human_clothing_icon = icon(file_to_use, state_to_use)

	if(!species_clothing_colors || !species_clothing_icon_state)
		// This clothing piece has no species specific clothing, use the normal icon
		GLOB.species_clothing_icons[species]["[file_to_use]-[state_to_use]"] = human_clothing_icon
		return

	var/icon/species_icon = icon(species, species_clothing_icon_state)
	var/list/final_list = list()
	for(var/i in 1 to 3)
		if(length(species_clothing_colors) < i)
			final_list += "#00000000"
			continue
		var/color = species_clothing_colors[i]
		if(islist(color)) // The entry is a list of x, y coordinates; find the color at this point
			final_list += human_clothing_icon.GetPixel(color[1], color[2]) || "#00000000"
		else if(istext(color))
			final_list += color

	species_icon.MapColors(final_list[1], final_list[2], final_list[3])
	species_icon = fcopy_rsc(species_icon)
	// Stores the icon in a global list; if it already exists, this proc is skipped
	GLOB.species_clothing_icons[species]["[file_to_use]-[state_to_use]"] = species_icon

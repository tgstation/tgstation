// Autowiki Stock Parts
/datum/autowiki/stock_parts
	page = "Template:Autowiki/Content/StockParts"

/datum/autowiki/stock_parts/generate()
	// Output string to append to autowiki data block
	var/output = ""

	// Find all valid stock parts and their references
	for(var/part_type in subtypesof(/obj/item/stock_parts))
		// Skip subspace subtype as it is a grouping subtype and invalid
		if(part_type == /obj/item/stock_parts/subspace)
			continue

		// Battery cells have a million variants we don't care about
		// All other battery types could possibly be put in another list?
		// As it is, power cells are barely stock parts with how much extra functionality they have
		if(ispath(part_type, /obj/item/stock_parts/cell))
			switch(part_type)
				if(/obj/item/stock_parts/cell)
				if(/obj/item/stock_parts/cell/high)
				if(/obj/item/stock_parts/cell/super)
				if(/obj/item/stock_parts/cell/hyper)
				if(/obj/item/stock_parts/cell/bluespace)
				else
					continue

		// Instantiate stock part
		var/obj/item/stock_parts/stock_part = new part_type()

		var/datum/design/recipe = find_design(stock_part)

		var/datum/techweb_node/required_node = find_research(recipe)

		// contains current loop iteration's template parameters in key value pairs
		var/list/entry_contents = list()

		// Populate entry_contents list
		entry_contents["name"]        = escape_value(format_text(stock_part.name))
		entry_contents["icon"]        = escape_value(format_text(create_icon(stock_part)))
		entry_contents["desc"]        = escape_value(format_text(stock_part.desc))
		entry_contents["type"]        = escape_value(format_text("[stock_part.type]"))
		entry_contents["id"]          = escape_value(format_text(recipe.id))
		entry_contents["tier"]        = escape_value(format_text("[stock_part.rating]"))
		entry_contents["sources"]     = escape_value(format_text(generate_source_list(recipe)))
		entry_contents["node"]        = escape_value(format_text(required_node.display_name))
		entry_contents["materials"]   = escape_value(format_text(generate_material_list(recipe)))

		// Place our completed template on the output string
		output += include_template("Autowiki/StockPart", entry_contents)

	return output

// Find the associated fabricator design for a stock part
/datum/autowiki/stock_parts/proc/find_design(obj/item/stock_parts/stock_part)
	for(var/design_type in subtypesof(/datum/design))
		var/datum/design/recipe = new design_type()

		if(ispath(recipe.build_path, stock_part.type))
			return recipe

// Find the associated research for a stock part
/datum/autowiki/stock_parts/proc/find_research(datum/design/recipe)
	for(var/node_type in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/node = new node_type()

		if(node.design_ids.Find(recipe.id))
			return node

// Create and upload a static icon to the wiki
/datum/autowiki/stock_parts/proc/create_icon(obj/item/stock_parts/stock_part)
	var/filename = SANITIZE_FILENAME(escape_value(stock_part.icon_state))
	upload_icon(icon(stock_part.icon, stock_part.icon_state, SOUTH, 1, FALSE), filename)

	return "Autowiki-" + filename + ".png"

// Generate a string of fabricators this part can be crafted from
/datum/autowiki/stock_parts/proc/generate_source_list(datum/design/recipe)
	// String for proc output
	var/source_list = ""

	// Check for Protolathe bitflag and add to list
	if((recipe.build_type & PROTOLATHE) == PROTOLATHE)
		source_list += "Protolathe"

	// Check for Ancient Protolathe bitflag and add to list, optionally add comma if not first
	if((recipe.build_type & AWAY_LATHE) == AWAY_LATHE)
		if(source_list)
			source_list += ", "

		source_list += "Ancient Protolathe"

	// Check for Autolathe bitflag and add to list, optionally add comma if not first
	if((recipe.build_type & AUTOLATHE) == AUTOLATHE)
		if(source_list)
			source_list += ", "

		source_list += "Autolathe"

	return source_list

// Generate a string of materials required to fabricate this part
/datum/autowiki/stock_parts/proc/generate_material_list(datum/design/recipe)
	// Is this the first list pass?
	var/initial = TRUE

	// String for proc output
	var/material_list = ""

	// Iterate over all list entries
	// List key is type, value is number representing cost
	for(var/ingredient_type in recipe.materials)
		var/datum/material/ingredient = new ingredient_type()
		// If we aren't the first entry, add a line break
		if(!initial)
			material_list += "<br>"

		// Append material cost to string list
		material_list += "[recipe.materials[ingredient_type]] "

		// Append material name to string list
		material_list += ingredient.name

		// Tell loop that we have already done an iteration in case this is the first
		initial = FALSE

	return material_list

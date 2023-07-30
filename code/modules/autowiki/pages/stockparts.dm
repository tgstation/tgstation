/// Automtically generated string list of stock part templates and relevant data for the /tg/station wiki
/datum/autowiki/stock_parts
	page = "Template:Autowiki/Content/StockParts"

	var/list/battery_whitelist = list(
		/obj/item/stock_parts/cell,
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/cell/super,
		/obj/item/stock_parts/cell/hyper,
		/obj/item/stock_parts/cell/bluespace,
	)

/datum/autowiki/stock_parts/generate()
	var/output = ""

	for(var/part_type in subtypesof(/obj/item/stock_parts))
		var/obj/item/stock_parts/type_to_check = part_type
		if(initial(type_to_check.abstract_type) == part_type)
			continue

		if(!battery_whitelist.Find(part_type) && ispath(part_type, /obj/item/stock_parts/cell))
			continue

		var/obj/item/stock_parts/stock_part = new part_type()

		var/datum/design/recipe = find_design(stock_part)

		if(!recipe)
			continue

		var/datum/techweb_node/required_node = find_research(recipe)

		var/list/entry_contents = list()

		entry_contents["name"] = escape_value(format_text(stock_part.name))
		entry_contents["icon"] = escape_value(format_text(create_icon(stock_part)))
		entry_contents["desc"] = escape_value(format_text(stock_part.desc))
		entry_contents["tier"] = escape_value(format_text("[stock_part.rating]"))
		entry_contents["sources"] = escape_value(format_text(generate_source_list(recipe)))
		entry_contents["node"] = escape_value(format_text(required_node.display_name))
		entry_contents["materials"] = escape_value(format_text(generate_material_list(recipe)))

		output += include_template("Autowiki/StockPart", entry_contents)

	return output

/datum/autowiki/stock_parts/proc/find_design(obj/item/stock_parts/stock_part)
	for(var/design_type in subtypesof(/datum/design))
		var/datum/design/recipe = new design_type()

		if(ispath(recipe.build_path, stock_part.type))
			return recipe

/datum/autowiki/stock_parts/proc/find_research(datum/design/recipe)
	for(var/node_type in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/node = new node_type()

		if(node.design_ids.Find(recipe.id))
			return node

/datum/autowiki/stock_parts/proc/create_icon(obj/item/stock_parts/stock_part)
	var/filename = SANITIZE_FILENAME(escape_value(stock_part.icon_state))
	upload_icon(icon(stock_part.icon, stock_part.icon_state, SOUTH, 1, FALSE), filename)

	return "Autowiki-[filename].png"

/datum/autowiki/stock_parts/proc/generate_source_list(datum/design/recipe)
	var/list/source_list = list()

	if(recipe.build_type & PROTOLATHE)
		source_list.Add("Protolathe")

	if(recipe.build_type & AWAY_LATHE)
		source_list.Add("Ancient Protolathe")

	if(recipe.build_type & AUTOLATHE)
		source_list.Add("Autolathe")

	return source_list.Join(", ")

/datum/autowiki/stock_parts/proc/generate_material_list(datum/design/recipe)
	var/list/materials = list()

	for(var/ingredient_type in recipe.materials)
		var/datum/material/ingredient = new ingredient_type()

		materials += "[recipe.materials[ingredient_type]] [ingredient.name]"

	return materials.Join("<br>")

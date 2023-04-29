/datum/autowiki/soup
	page = "Template:Autowiki/Content/SoupRecipes"

/datum/autowiki/soup/generate()
	var/output = ""

	// Since we're here, generate a range icon since that's what is installed in most kitchens
	var/obj/machinery/oven/range/range = new()
	upload_icon(getFlatIcon(range, no_anim = TRUE), "kitchen_range")
	qdel(range)

	// Also generate a soup pot icon, as that's what makes soup
	var/obj/item/reagent_containers/cup/soup_pot/soup_pot = new()
	upload_icon(getFlatIcon(soup_pot, no_anim = TRUE), "soup_pot")
	qdel(soup_pot)

	var/container_for_images = /obj/item/reagent_containers/cup/bowl

	for(var/soup_recipe_type in subtypesof(/datum/chemical_reaction/food/soup))
		var/datum/chemical_reaction/food/soup/soup_recipe = new soup_recipe_type()
		var/result_soup_type = soup_recipe.results[1]
		var/datum/reagent/result_soup = new result_soup_type()
		var/datum/glass_style/has_foodtype/soup_style = GLOB.glass_style_singletons[container_for_images][result_soup_type]
		var/filename = "soup_[SANITIZE_FILENAME(escape_value(format_text(result_soup.name)))]"

		// -- Compiles a list of required reagents and food items --
		var/list/all_needs_text = list()
		for(var/datum/reagent/reagent_type as anything in soup_recipe.required_reagents)
			var/num_needed = soup_recipe.required_reagents[reagent_type]
			all_needs_text += "[num_needed] units [initial(reagent_type.name)]"

		for(var/obj/item/food_type as anything in soup_recipe.required_ingredients)
			var/num_needed = soup_recipe.required_ingredients[food_type]
			// Instantiating this so we can do plurality correctly.
			// We can use initial but it'll give us stuff like "eyballss".
			var/obj/item/food = new food_type()
			all_needs_text += "[num_needed] [food.name]\s"
			qdel(food)

		all_needs_text += soup_recipe.describe_recipe_details()
		all_needs_text += "At temperature [soup_recipe.required_temp]K"
		var/compiled_requirements = ""
		for(var/req_text in all_needs_text)
			if(length(req_text))
				compiled_requirements += "<li>[req_text]</li>"
		if(length(compiled_requirements))
			compiled_requirements = "<ul>[compiled_requirements]</ul>"

		// -- Compiles a list of resulting reagents --
		var/list/all_results_text = list()
		for(var/datum/reagent/reagent_type as anything in soup_recipe.results)
			var/num_given = soup_recipe.results[reagent_type]
			all_results_text += "[num_given] units [initial(reagent_type.name)]"

		all_results_text += soup_recipe.describe_result()
		var/compiled_results = ""
		for(var/res_text in all_results_text)
			if(length(res_text))
				compiled_results += "<li>[res_text]</li>"
		if(length(compiled_results))
			compiled_results = "<ul>[compiled_results]</ul>"

		// -- Assemble the template list --
		var/list/template_list = list()
		if(istype(soup_recipe, /datum/chemical_reaction/food/soup/custom))
			// Painful snowflaking here for custom recipes,
			// but because they default to "bowl of water" we can't let it generate fully on its own.
			template_list["name"] = "Custom Soup"
			template_list["taste"] = "Whatever you use."
			template_list["foodtypes"] = "Whatever you use."
			template_list["description"] = "A custom soup recipe, allowing you to throw whatever you want in the pot."

		else
			var/foodtypes_readable = jointext(bitfield_to_list(soup_style.drink_type, FOOD_FLAGS_IC), ", ") || "None"
			var/tastes_actual = result_soup.get_taste_description()
			template_list["name"] = escape_value(result_soup.name)
			template_list["taste"] = escape_value(length(tastes_actual) ? capitalize(jointext(tastes_actual, ", ")) : "No taste")
			template_list["foodtypes"] = escape_value(foodtypes_readable)
			template_list["description"] = escape_value(result_soup.description)

		template_list["icon"] = escape_value(filename)
		template_list["requirements"] = escape_value(compiled_requirements)
		template_list["results"] = escape_value(compiled_results)

		// -- While we're here, generate an icon of the bowl --
		var/image/compiled_image = image(icon = soup_style.icon, icon_state = soup_style.icon_state)
		upload_icon(getFlatIcon(compiled_image, no_anim = TRUE), filename)

		// -- Cleanup --
		qdel(result_soup)
		qdel(soup_recipe)

		// -- All done, apply the template --
		output += include_template("Autowiki/SoupRecipeTemplate", template_list)

	// All that gets wrapped in another template which formats it into a table
	return include_template("Autowiki/SoupRecipeTableTemplate", list("content" = output))

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
		// Used to determine what icon is displayed on the wiki
		var/soup_icon
		var/soup_icon_state
		// Used to determine what food types the soup is
		var/soup_food_types = NONE
		// Used for filename and description of the result
		var/result_name
		var/result_desc
		var/result_tastes
		// Solid food item results take priority over reagents for showcasing results
		if(soup_recipe.resulting_food_path)
			var/obj/item/resulting_food = new soup_recipe.resulting_food_path()
			result_name = format_text(resulting_food.name)
			result_desc = resulting_food.desc

			soup_icon = resulting_food.icon
			soup_icon_state = resulting_food.icon_state

			if(istype(resulting_food, /obj/item/food))
				var/obj/item/food/resulting_food_casted = resulting_food
				result_tastes = resulting_food_casted.tastes?.Copy()
				soup_food_types = resulting_food_casted.foodtypes || NONE

			qdel(resulting_food)

		// Otherwise, it should be a reagent.
		else
			var/result_soup_type = soup_recipe.results[1]
			var/datum/reagent/result_soup = new result_soup_type()
			result_name = format_text(result_soup.name)
			result_desc = result_soup.description
			result_tastes = result_soup.get_taste_description()

			var/datum/glass_style/has_foodtype/soup_style = GLOB.glass_style_singletons[container_for_images][result_soup_type]
			soup_icon = soup_style.icon
			soup_icon_state = soup_style.icon_state
			soup_food_types = soup_style.drink_type

			qdel(result_soup)

		var/filename = "soup_[SANITIZE_FILENAME(escape_value(result_name))]"

		// -- Compiles a list of required reagents and food items --
		var/list/all_needs_text = list()
		for(var/datum/reagent/reagent_type as anything in soup_recipe.required_reagents)
			all_needs_text += "[soup_recipe.required_reagents[reagent_type]] units [initial(reagent_type.name)]"
		for(var/datum/reagent/reagent_type as anything in soup_recipe.required_catalysts)
			all_needs_text += "[soup_recipe.required_catalysts[reagent_type]] units [initial(reagent_type.name)] (not consumed)"

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
		if(soup_recipe.resulting_food_path)
			all_results_text += "1 [initial(soup_recipe.resulting_food_path.name)]"

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
			var/foodtypes_readable = jointext(bitfield_to_list(soup_food_types, FOOD_FLAGS_IC), ", ") || "None"
			template_list["name"] = escape_value(result_name)
			template_list["taste"] = escape_value(length(result_tastes) ? capitalize(jointext(result_tastes, ", ")) : "No taste")
			template_list["foodtypes"] = escape_value(foodtypes_readable)
			template_list["description"] = escape_value(result_desc)

		template_list["icon"] = escape_value(filename)
		template_list["requirements"] = escape_value(compiled_requirements)
		template_list["results"] = escape_value(compiled_results)

		// -- While we're here, generate an icon of the bowl --
		var/image/compiled_image = image(icon = soup_icon, icon_state = soup_icon_state)
		upload_icon(getFlatIcon(compiled_image, no_anim = TRUE), filename)

		// -- Cleanup --
		qdel(soup_recipe)

		// -- All done, apply the template --
		output += include_template("Autowiki/SoupRecipeTemplate", template_list)

	// All that gets wrapped in another template which formats it into a table
	return include_template("Autowiki/SoupRecipeTableTemplate", list("content" = output))

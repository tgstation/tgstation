/proc/init_doppler_stack_recipes()
	var/list/additional_stack_recipes = list(
		/obj/item/stack/sheet/leather = list(GLOB.doppler_leather_recipes, GLOB.doppler_leather_belt_recipes),
		/obj/item/stack/sheet/iron = list(GLOB.doppler_metal_recipes),
		/obj/item/stack/sheet/plasteel = list(GLOB.doppler_plasteel_recipes),
		/obj/item/stack/sheet/mineral/wood = list(GLOB.doppler_wood_recipes),
		/obj/item/stack/sheet/cloth = list(GLOB.doppler_cloth_recipes),
		/obj/item/stack/ore/glass = list(GLOB.doppler_sand_recipes),
		/obj/item/stack/rods = list(GLOB.doppler_rod_recipes),
		/obj/item/stack/sheet/mineral/stone = list(GLOB.stone_recipes),
		/obj/item/stack/sheet/mineral/clay = list(GLOB.clay_recipes),
	)
	for(var/stack in additional_stack_recipes)
		for(var/material_list in additional_stack_recipes[stack])
			for(var/stack_recipe in material_list)
				if(istype(stack_recipe, /datum/stack_recipe_list))
					var/datum/stack_recipe_list/stack_recipe_list = stack_recipe
					for(var/nested_recipe in stack_recipe_list.recipes)
						if(!nested_recipe)
							continue
						var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, nested_recipe)
						if(recipe.name != "" && recipe.result)
							GLOB.crafting_recipes += recipe
				else
					if(!stack_recipe)
						continue
					var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, stack_recipe)
					if(recipe.name != "" && recipe.result)
						GLOB.crafting_recipes += recipe

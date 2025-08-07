///Abstract class to allow us to easily create all the generic "normal" food without too much copy pasta of adding more components
/obj/item/food
	name = "food"
	desc = "you eat this"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	grind_results = list()
	material_flags = MATERIAL_NO_EDIBILITY
	/**
	 * A list of material paths. the main material in the custom_materials list is also added on init.
	 *
	 * If the food has materials and as long as the main one is in this list, effects and properties of materials are disabled
	 * Food is coded mainly around reagents than materials, and the two may cause some issues if overlapped. For example, this
	 * stops food *normally* containing meat from having redundant prefixes, an unfitting appearance and too much meatiness overall.
	 * However, the same material effects will apply on a fruit or a vegetable.
	 */
	var/list/intrinsic_food_materials
	///List of reagents this food gets on creation during reaction or map spawn
	var/list/food_reagents
	///Extra flags for things such as if the food is in a container or not
	var/food_flags
	///Bitflag of the types of food this food is
	var/foodtypes
	///Amount of volume the food can contain
	var/max_volume
	///How long it will take to eat this food without any other modifiers
	var/eat_time
	///Tastes to describe this food
	var/list/tastes
	///Verbs used when eating this food in the to_chat messages
	var/list/eatverbs
	///How much reagents per bite
	var/bite_consumption
	///Type of atom thats spawned after eating this item
	var/trash_type
	///How much junkiness this food has? God I should remove junkiness soon
	var/junkiness
	///Price of this food if sold in a venue
	var/venue_value
	///Food that's immune to decomposition.
	var/preserved_food = FALSE
	///Does our food normally attract ants?
	var/ant_attracting = FALSE
	///What our food decomposes into.
	var/decomp_type = /obj/item/food/badrecipe/moldy
	///Food that needs to be picked up in order to decompose.
	var/decomp_req_handle = FALSE
	///Used to set custom decomposition times for food. Set to 0 to have it automatically set via the food's flags.
	var/decomposition_time = 0
	///Used to set decomposition stink particles for food, will have no particles if null
	var/decomposition_particles = /particles/stink
	///Used to set custom starting reagent purity for synthetic and natural food. Ignored when set to null.
	var/starting_reagent_purity = null
	///How exquisite the meal is. Applicable to crafted food, increasing its quality. Spans from 0 to 5.
	var/crafting_complexity = 0
	///Buff given when a hand-crafted version of this item is consumed. Randomized according to crafting_complexity if not assigned.
	var/datum/status_effect/food/crafted_food_buff = null

/obj/item/food/Initialize(mapload)
	if(food_reagents)
		food_reagents = string_assoc_list(food_reagents)

	///This has to be done before set_custom_materials is called at atom level
	if(custom_materials)
		var/main_mat_type = null
		var/mat_amount = 0
		for(var/mat_type in custom_materials)
			if(custom_materials[mat_type] > mat_amount)
				main_mat_type = mat_type
		LAZYADD(intrinsic_food_materials, main_mat_type)
	if(intrinsic_food_materials)
		intrinsic_food_materials = typecacheof(intrinsic_food_materials)

	. = ..()

	if(tastes)
		tastes = string_assoc_list(tastes)
	if(eatverbs)
		eatverbs = string_list(eatverbs)
	if(venue_value)
		AddElement(/datum/element/venue_price, venue_value)
	make_edible()
	make_processable()
	make_leave_trash()
	make_grillable()
	make_germ_sensitive(mapload)
	make_bakeable()
	make_microwaveable()
	ADD_TRAIT(src, TRAIT_FISHING_BAIT, INNATE_TRAIT)

/obj/item/food/apply_material_effects(list/materials)
	if(!HAS_TRAIT(src, TRAIT_INGREDIENTS_HOLDER)) //ingredients holder handle prefixes and colors differently
		var/datum/material/main_material = materials[1] //The list is sorted by amount so the first of the list is the main mat
		if(!is_type_in_typecache(main_material, intrinsic_food_materials))
			material_flags |= MATERIAL_EFFECTS|MATERIAL_AFFECT_STATISTICS|MATERIAL_ADD_PREFIX|MATERIAL_COLOR
	else
		//food items with the ingredients holders component are still affected by the materials stats and effects wise.
		material_flags |= MATERIAL_EFFECTS|MATERIAL_AFFECT_STATISTICS
	return ..()

/obj/item/food/remove_material_effects(replace_mats = TRUE)
	. = ..()
	material_flags &= ~(MATERIAL_EFFECTS|MATERIAL_AFFECT_STATISTICS|MATERIAL_ADD_PREFIX|MATERIAL_COLOR)

///This proc adds the edible component, overwrite this if you for some reason want to change some specific args like callbacks.
/obj/item/food/proc/make_edible()
	AddComponentFrom(
		SOURCE_EDIBLE_INNATE,\
		/datum/component/edible,\
		initial_reagents = food_reagents,\
		food_flags = food_flags,\
		foodtypes = foodtypes,\
		volume = max_volume,\
		eat_time = eat_time,\
		tastes = tastes,\
		eatverbs = eatverbs,\
		bite_consumption = bite_consumption,\
		junkiness = junkiness,\
		reagent_purity = starting_reagent_purity,\
	)

/obj/item/food/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	for(var/obj/item/item in components) // parent proc assumes machinery or structures in components are used, so we should be fine to assume only items from here
		if(!istype(item, /obj/item/food))
			continue
		var/obj/item/food/food_component = item
		LAZYADD(intrinsic_food_materials, food_component.intrinsic_food_materials)
	var/mob/living/user = crafter
	if(istype(user) && !isnull(user.mind))
		ADD_TRAIT(src, TRAIT_FOOD_CHEF_MADE, REF(user.mind))

///This proc handles processable elements, overwrite this if you want to add behavior such as slicing, forking, spooning, whatever, to turn the item into something else
/obj/item/food/proc/make_processable()
	return

///This proc handles grillable components, overwrite if you want different grill results etc.
/obj/item/food/proc/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/badrecipe, rand(20 SECONDS, 30 SECONDS), FALSE)
	return

///This proc handles bakeable components, overwrite if you want different bake results etc.
/obj/item/food/proc/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/badrecipe, rand(25 SECONDS, 40 SECONDS), FALSE)
	return

/// This proc handles the microwave component. Overwrite if you want special microwave results.
/// By default, all food is microwavable. However, they will be microwaved into a bad recipe (burnt mess).
/obj/item/food/proc/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/badrecipe, skip_matcheck = TRUE)

///This proc handles trash components, overwrite this if you want the object to spawn trash
/obj/item/food/proc/make_leave_trash()
	if(trash_type)
		AddElement(/datum/element/food_trash, trash_type)
	return

///This proc makes things infective and decomposing when they stay on the floor for too long.
///Set preserved_food to TRUE to make it never decompose.
///Set decomp_req_handle to TRUE to only make it decompose when someone picks it up.
///Requires /datum/component/germ_sensitive to detect exposure
/obj/item/food/proc/make_germ_sensitive(mapload)
	if(!isnull(trash_type))
		return // You don't eat the package and it protects from decomposing
	AddComponent(/datum/component/germ_sensitive, mapload)
	if(!preserved_food)
		AddComponent(/datum/component/decomposition, mapload, decomp_req_handle, decomp_flags = foodtypes, decomp_result = decomp_type, ant_attracting = ant_attracting, custom_time = decomposition_time, stink_particles = decomposition_particles)

/obj/item/food/on_craft_completion(list/components, datum/crafting_recipe/food/current_recipe, atom/crafter)
	. = ..()
	if(!istype(current_recipe))
		return

	var/made_with_food = FALSE
	var/final_foodtypes = current_recipe.added_foodtypes
	for(var/obj/item/food/ingredient in components)
		made_with_food = TRUE
		final_foodtypes |= ingredient.foodtypes
	if(!made_with_food)
		return
	final_foodtypes &= ~current_recipe.removed_foodtypes
	///Update the foodtypes
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, foodtypes = final_foodtypes)

/obj/item/food/OnCreatedFromProcessing(mob/living/user, obj/item/work_tool, list/chosen_option, atom/original_atom)
	. = ..()
	if(!istype(original_atom, /obj/item/food))
		return
	var/obj/item/food/original_food = original_atom
	if(original_food.intrinsic_food_materials)
		LAZYADD(intrinsic_food_materials, original_food.intrinsic_food_materials)

/obj/structure/anvil
	name = "anvil"
	desc = "Great for forging."

	density = TRUE
	anchored = TRUE

	icon = 'monkestation/code/modules/smithing/icons/forge_structures.dmi'
	icon_state = "anvil_empty"

	var/datum/anvil_recipe/chosen_recipe

	var/obj/item/working_material
	var/smithing = FALSE

	var/list/recipes = list()
	var/list/name_to_type = list()

/obj/structure/anvil/Initialize(mapload)
	. = ..()
	for(var/datum/anvil_recipe/recipe as anything in subtypesof(/datum/anvil_recipe))
		name_to_type |= list(initial(recipe.name) = recipe)
		var/image/new_image = image(icon = initial(recipe.output.icon), icon_state = initial(recipe.output.icon_state))
		recipes |= list(initial(recipe.name) = new_image)
	register_context()

/obj/structure/anvil/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!chosen_recipe)
		context[SCREENTIP_CONTEXT_LMB] = "Select a part to forge."
	else
		context[SCREENTIP_CONTEXT_LMB] = "Try to forge."

	if(chosen_recipe)
		context[SCREENTIP_CONTEXT_RMB] = "Clear Recipe."
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/anvil/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!chosen_recipe)
		var/pick = show_radial_menu(user, src, recipes, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
		if(!pick)
			return
		if(!(pick in name_to_type))
			return
		chosen_recipe = name_to_type[pick]

	if(!smithing && working_material && chosen_recipe && working_material.material_stats)
		var/density_hardness = 0
		density_hardness = working_material.material_stats.hardness + working_material.material_stats.density

		var/difficulty_modifier = density_hardness / 30

		new /datum/anvil_challenge(src, new chosen_recipe, user, difficulty_modifier)
		smithing = TRUE

/obj/structure/anvil/attack_hand_secondary(mob/user, list/modifiers)
	if(chosen_recipe)
		chosen_recipe = null
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	. = ..()

/obj/structure/anvil/proc/generate_item(quality)
	var/obj/item/smithed_part/new_part = chosen_recipe.output
	new new_part (get_turf(src), working_material, quality)
	QDEL_NULL(working_material)

/obj/structure/anvil/attackby(obj/item/attacking_item, mob/living/user, params)
	if((isstack(attacking_item) || istype(attacking_item, /obj/item/merged_material)) && !smithing)
		if(try_place_item(attacking_item, user))
			return
	return ..()

/obj/structure/anvil/proc/try_place_item(obj/item/item, mob/living/user)
	if(working_material)
		working_material.forceMove(get_turf(src))
		working_material = null
		visible_message("[user] replaces the ingot on the anvil.")

	if(isstack(item))
		var/obj/item/stack/stack = item
		if(!stack.material_type)
			working_material = null
			return FALSE
		if(stack.amount == 1)
			item.forceMove(src)
			working_material = item
		else
			var/obj/item/stack/new_stack = stack.split_stack(user, 1)
			new_stack.forceMove(src)
			working_material = new_stack
	else if(istype(item, /obj/item/merged_material))
		item.forceMove(src)
		working_material = item
	return TRUE

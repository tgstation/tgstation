/obj/structure/machine/assembly_bench
	name = "assembly bench"
	desc = "Can be used to assemble smithed parts together."

	density = TRUE
	anchored = TRUE

	icon = 'monkestation/code/modules/smithing/icons/forge_structures.dmi'
	icon_state = "crafting_bench_empty"

	var/list/recipes = list()
	var/datum/assembly_recipe/current_recipe
	var/list/stored_items = list()
	var/obj/item/held_starting_item

/obj/structure/machine/assembly_bench/Initialize(mapload)
	. = ..()
	for(var/datum/assembly_recipe/subtype as anything in subtypesof(/datum/assembly_recipe) - /datum/assembly_recipe/smithed_weapon)
		recipes += new subtype

/obj/structure/machine/assembly_bench/examine(mob/user)
	. = ..()
	if(current_recipe)
		for(var/obj/item/item as anything in current_recipe.needed_items)
			. += span_notice("[current_recipe.needed_items[item]] [initial(item.name)] needed.")

/obj/structure/machine/assembly_bench/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!current_recipe)
		for(var/datum/assembly_recipe/recipe as anything in recipes)
			if(recipe.item_to_start != attacking_item.type)
				continue
			current_recipe = new recipe.type
			current_recipe.parent = src
			attacking_item.forceMove(src)
			stored_items += attacking_item
			held_starting_item = attacking_item
			return

	if(current_recipe)
		for(var/item in current_recipe.needed_items)
			if(istype(attacking_item, item))
				current_recipe.needed_items[item]--

				if(isstack(attacking_item))
					var/obj/item/stack/stack = attacking_item
					if(stack.amount == 1)
						attacking_item.forceMove(src)
					else
						var/obj/item/stack/new_stack = stack.split_stack(user, 1)
						attacking_item = new_stack
						new_stack.forceMove(src)
				else
					attacking_item.forceMove(src)

				stored_items += attacking_item
				if((!current_recipe.needed_items[item]) || current_recipe.needed_items[item] <= 0)
					current_recipe.needed_items -= item
				if(!length(current_recipe.needed_items))
					try_complete_recipe(user)
				return
	return ..()

/obj/structure/machine/assembly_bench/proc/try_complete_recipe(mob/living/user)
	if(!current_recipe)
		return
	if(length(current_recipe.needed_items))
		return
	if(do_after(user, current_recipe.craft_time, src))
		current_recipe.complete_recipe()

/obj/structure/machine/assembly_bench/attack_hand(mob/living/user, list/modifiers)
	try_complete_recipe(user)
	. = ..()

/obj/structure/machine/assembly_bench/proc/clear_recipe()
	current_recipe.parent = null
	held_starting_item = null
	QDEL_NULL(current_recipe)

	QDEL_LIST(stored_items)
	stored_items = list()

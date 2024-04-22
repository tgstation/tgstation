/datum/assembly_recipe
	var/obj/structure/machine/assembly_bench/parent
	var/list/needed_items = list()
	var/obj/item/output_item
	var/obj/item/item_to_start
	var/craft_time = 1 SECONDS

/datum/assembly_recipe/proc/attempt_add_item(obj/item/adder)
	if(adder.type in needed_items)
		needed_items[adder.type]--
		if(!needed_items[adder.type])
			needed_items -= adder.type
	if(!length(needed_items))
		complete_recipe()

/datum/assembly_recipe/proc/complete_recipe()
	new output_item(get_turf(parent))
	parent.clear_recipe()


/datum/assembly_recipe/smithed_weapon/complete_recipe()
	var/obj/item/smithed_part/weapon_part/parent_holder_item = parent.held_starting_item
	parent_holder_item.finish_weapon()
	parent_holder_item.forceMove(get_turf(parent))
	parent.stored_items -= parent.held_starting_item
	parent.clear_recipe()


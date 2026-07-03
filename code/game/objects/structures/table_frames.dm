/* Table Frames
 * Contains:
 * Frames
 * Wooden Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Четыре металлические ножки с четырьмя каркасными стержнями для стола. Вы легко сможете пройти через это."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	max_integrity = 100
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2

/obj/structure/table_frame/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/table_frame/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		context[SCREENTIP_CONTEXT_RMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET

	if(isstack(held_item) && get_table_type(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Собрать стол"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/table_frame/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "разборка...")
	tool.play_tool_sound(src)
	if(!tool.use_tool(src, user, 3 SECONDS))
		return ITEM_INTERACT_BLOCKING
	playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/table_frame/wrench_act_secondary(mob/living/user, obj/item/tool)
	return wrench_act(user, tool)

/obj/structure/table_frame/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isstack(tool))
		return NONE
	var/obj/item/stack/our_stack = tool
	var/table_type = get_table_type(our_stack)
	if(isnull(table_type))
		return NONE

	if(our_stack.get_amount() < 1)
		balloon_alert(user, "нужно больше материала!")
		return ITEM_INTERACT_BLOCKING

	// Check if the turf is blocked by dense objects or objects that block construction
	for(var/obj/object in loc)
		if(object.pass_flags & PASSTABLE)
			continue
		if((object.density && !(object.obj_flags & IGNORE_DENSITY)) || object.obj_flags & BLOCKS_CONSTRUCTION)
			balloon_alert(user, "[object.name] is in the way!")
			return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "сборка стола...")
	if(!do_after(user, 2 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING

	// Check again after the delay in case something was placed during construction
	for(var/obj/object in loc)
		if(object.pass_flags & PASSTABLE)
			continue
		if((object.density && !(object.obj_flags & IGNORE_DENSITY)) || object.obj_flags & BLOCKS_CONSTRUCTION)
			balloon_alert(user, "[object.name] is in the way!")
			return ITEM_INTERACT_BLOCKING

	if(!our_stack.use(1))
		return ITEM_INTERACT_BLOCKING

	new table_type(loc, src, our_stack)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Gets the table type we make with our given stack.
/obj/structure/table_frame/proc/get_table_type(obj/item/stack/our_stack)
	return our_stack.get_table_type()

/obj/structure/table_frame/atom_deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)

/obj/structure/table_frame/narsie_act()
	new /obj/structure/table_frame/wood(src.loc)
	qdel(src)

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Четыре деревянные ножки с четырьмя деревянными каркасными стержнями для деревянного стола. Вы легко сможете пройти через это."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/table_frame/wood/get_table_type(obj/item/stack/our_stack)
	if(istype(our_stack, /obj/item/stack/sheet/mineral/wood))
		return /obj/structure/table/wood
	if(istype(our_stack, /obj/item/stack/tile/carpet))
		return /obj/structure/table/wood/poker

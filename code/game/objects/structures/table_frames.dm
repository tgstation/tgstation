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
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
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
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	if(isstack(held_item) && get_table_type(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Construct table"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/table_frame/wrench_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "deconstructing...")
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
		balloon_alert(user, "need more material!")
		return ITEM_INTERACT_BLOCKING
	if(locate(/obj/structure/table) in loc)
		balloon_alert(user, "can't stack tables!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "constructing table...")
	if(!do_after(user, 2 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	if((locate(/obj/structure/table) in loc) || !our_stack.use(1))
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
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE

/obj/structure/table_frame/wood/get_table_type(obj/item/stack/our_stack)
	if(istype(our_stack, /obj/item/stack/sheet/mineral/wood))
		return /obj/structure/table/wood
	if(istype(our_stack, /obj/item/stack/tile/carpet))
		return /obj/structure/table/wood/poker

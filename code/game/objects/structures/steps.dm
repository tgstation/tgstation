/// Short stairs you can use to climb tables quickly
/obj/structure/steps
	name = "steps"
	desc = "A small set of steps you can use to reach high shelves or climb onto platforms, just watch your ankles."
	icon = 'icons/obj/small_stairs.dmi'
	icon_state = "iron"
	anchored = TRUE
	move_resist = INFINITY

/obj/structure/steps/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter),
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/climb_walkable)
	AddComponent(/datum/component/simple_rotation)
	register_context()

/obj/structure/steps/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!held_item)
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/steps/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/steps/screwdriver_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You start disassembling [src]..."))
	if(tool.use_tool(src, user, 2 SECONDS, volume=50))
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/steps/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location(), 2)

/// Watch your ankles
/obj/structure/steps/proc/on_enter(turf/our_turf, mob/living/arrived, turf/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if (!isliving(arrived) || !isturf(old_loc) || !our_turf.Adjacent(old_loc) || !has_gravity(src) || HAS_TRAIT(arrived, TRAIT_MOB_ELEVATED) || (arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) || arrived.move_intent != MOVE_INTENT_RUN)
		return
	var/entered_dir = get_dir(our_turf, old_loc)
	if (entered_dir == dir)
		arrived.Knockdown(1 SECONDS)
		to_chat(arrived, span_warning("You tripped over \the [src]!"))

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/steps, 0)

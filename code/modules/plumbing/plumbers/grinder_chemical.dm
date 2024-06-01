/obj/machinery/plumbing/grinder_chemical
	name = "chemical grinder"
	desc = "Chemical grinder. Can either grind or juice stuff you put in."
	icon_state = "grinder_chemical"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 400

/obj/machinery/plumbing/grinder_chemical/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/plumbing/grinder_chemical/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(user.combat_mode)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(istype(tool, /obj/item/construction/plumbing))
		return tool.interact_with_atom(src, user, modifiers)
	else if(istype(tool, /obj/item/plunger))
		return
	else if(istype(tool, /obj/item/storage/bag))
		if(!anchored)
			to_chat(user, span_warning("Anchor first to star grinding."))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You dump items from [tool] into the grinder."))
		for(var/obj/item/obj_item in tool.contents)
			grind(obj_item)
		return ITEM_INTERACT_SUCCESS
	else if(!tool.tool_behaviour)
		if(!anchored)
			to_chat(user, span_warning("Anchor first to star grinding."))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You attempt to grind [tool]."))
		grind(tool)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/plumbing/grinder_chemical/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(!istype(mover, /obj/item))
		return FALSE
	return TRUE

/obj/machinery/plumbing/grinder_chemical/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	grind(AM)

/**
 * Grinds/Juices the atom
 * Arguments
 * * [AM][atom] - the atom to grind or juice
 */
/obj/machinery/plumbing/grinder_chemical/proc/grind(atom/AM)
	if(!is_operational)
		return
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return

	var/obj/item/I = AM
	if((I.item_flags & ABSTRACT) || (I.flags_1 & HOLOGRAM_1))
		return

	var/result
	if(I.grind_results)
		result = I.grind(reagents, usr)
	else
		result = I.juice(reagents, usr)
	if(result)
		use_energy(active_power_usage)
		qdel(I)

/obj/machinery/plumbing/grinder_chemical
	name = "chemical grinder"
	desc = "Chemical grinder. Can either grind or juice stuff you put in."
	icon_state = "grinder_chemical"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 400

	/// Are we grinding or juicing
	var/grinding = TRUE

/obj/machinery/plumbing/grinder_chemical/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/plumbing/grinder_chemical/examine(mob/user)
	. = ..()

	. += span_notice("Use empty hand to change operation mode. Currently [grinding ? "Grinding" : "Juicing"]")

/**
 * Check if the user can interact with the grinder
 * Arguments
 *
 * * mob/user - the player we are checking for
 */
/obj/machinery/plumbing/grinder_chemical/proc/check_interactable(mob/user)
	PRIVATE_PROC(TRUE)

	return can_interact(user)

/obj/machinery/plumbing/grinder_chemical/attack_hand(mob/living/user, list/modifiers)
	if(user.combat_mode || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return FALSE

	var/list/options = list()

	var/static/radial_grind = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_grind")
	options["grind"] = radial_grind

	var/static/radial_juice = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_juice")
	options["juice"] = radial_juice

	var/choice = show_radial_menu(
		user,
		src,
		options,
		custom_check = CALLBACK(src, PROC_REF(check_interactable), user),
	)
	if(!choice)
		return FALSE

	grinding = (choice == "grind")
	return TRUE

/obj/machinery/plumbing/grinder_chemical/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(user.combat_mode || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(istype(tool, /obj/item/construction/plumbing))
		return tool.interact_with_atom(src, user, modifiers)
	else if(istype(tool, /obj/item/plunger))
		return
	else if(istype(tool, /obj/item/storage/bag))
		if(!anchored)
			to_chat(user, span_warning("Anchor first to start [grinding ? "grind" : "juice"]."))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You dump items from [tool] into the grinder."))
		for(var/obj/item/obj_item in tool.contents)
			grind(obj_item)
		return ITEM_INTERACT_SUCCESS
	else if(!tool.tool_behaviour)
		var/action = "[grinding ? "grind" : "juice"]"
		if(!anchored)
			to_chat(user, span_warning("Anchor first to star [action]."))
			return ITEM_INTERACT_BLOCKING

		to_chat(user, span_notice("You attempt to [action] [tool]."))
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

	INVOKE_ASYNC(src, PROC_REF(grind), AM)

/**
 * Grinds/Juices the atom
 * Arguments
 * * [AM][atom] - the atom to grind or juice
 */
/obj/machinery/plumbing/grinder_chemical/proc/grind(atom/AM)
	PRIVATE_PROC(TRUE)

	if(!is_operational || !anchored)
		return
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return

	var/obj/item/I = AM
	if((I.item_flags & ABSTRACT) || (I.flags_1 & HOLOGRAM_1))
		return

	var/result
	if(!grinding)
		result = I.juice(reagents, usr)
	else if(length(I.grind_results) || I.reagents?.total_volume)
		result = I.grind(reagents, usr)

	use_energy(active_power_usage)
	if(result)
		qdel(I)

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

/obj/machinery/plumbing/grinder_chemical/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/storage/bag))
		to_chat(user, span_notice("You dump items from [weapon] into the grinder."))
		for(var/obj/item/obj_item in weapon.contents)
			grind(obj_item)
	else
		to_chat(user, span_notice("You attempt to grind [weapon]."))
		grind(weapon)

	return TRUE

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
	var/result
	if(I.grind_results)
		result = I.grind(reagents, usr)
	else
		result = I.juice(reagents, usr)
	if(result)
		use_energy(active_power_usage)
		qdel(I)

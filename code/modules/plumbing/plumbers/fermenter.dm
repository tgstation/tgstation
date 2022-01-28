/obj/machinery/plumbing/fermenter
	name = "chemical fermenter"
	desc = "Turns plants into various types of booze."
	icon_state = "fermenter"
	layer = ABOVE_ALL_MOB_LAYER

	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 400

	///input dir
	var/eat_dir = SOUTH

/obj/machinery/plumbing/fermenter/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/plumbing/fermenter/setDir(newdir)
	. = ..()
	eat_dir = newdir

/obj/machinery/plumbing/fermenter/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(border_dir == eat_dir)
		return TRUE

/obj/machinery/plumbing/fermenter/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	ferment(AM)

/// uses fermentation proc similar to fermentation barrels
/obj/machinery/plumbing/fermenter/proc/ferment(atom/AM)
	if(machine_stat & NOPOWER)
		return
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return
	if(istype(AM, /obj/item/food/grown))
		var/obj/item/food/grown/G = AM
		if(G.distill_reagent)
			var/amount = G.seed.potency * 0.25
			reagents.add_reagent(G.distill_reagent, amount)
			qdel(G)

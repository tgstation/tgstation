/obj/structure/chemical_input/fermenter
	name = "remote chemical fermenter"
	desc = "Turns plants into various types of booze."
	icon_state = "fermenter"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	reagent_flags = TRANSPARENT | DRAINABLE
	component_name = "Fermenter Input"
	density = FALSE


/obj/structure/chemical_input/fermenter/Initialize(mapload, bolt, layer)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/chemical_input/fermenter/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	ferment(AM)

/// uses fermentation proc similar to fermentation barrels
/obj/structure/chemical_input/fermenter/proc/ferment(atom/AM)
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

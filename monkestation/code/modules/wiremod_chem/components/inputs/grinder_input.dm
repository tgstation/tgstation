/obj/structure/chemical_input/grinder
	name = "remote chemical grinder"
	desc = "grinds stuff in chemical."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "grinder_chemical"
	reagent_flags = TRANSPARENT | DRAINABLE
	component_name = "Grinder Input"
	density = FALSE

/obj/structure/chemical_input/grinder/Initialize(mapload, bolt, layer)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/chemical_input/grinder/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	grind(AM)

/obj/structure/chemical_input/grinder/proc/grind(atom/AM)
	if(reagents.holder_full())
		return
	if(!isitem(AM))
		return
	var/obj/item/I = AM
	if(I.juice_results || I.grind_results)
		if(I.juice_results)
			I.on_juice()
			reagents.add_reagent_list(I.juice_results)
			if(I.reagents)
				I.reagents.trans_to(src, I.reagents.total_volume, transfered_by = src)
			qdel(I)
			return
		I.on_grind()
		reagents.add_reagent_list(I.grind_results)
		if(I.reagents)
			I.reagents.trans_to(src, I.reagents.total_volume, transfered_by = src)
		qdel(I)

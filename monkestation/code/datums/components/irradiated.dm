/datum/component/irradiated/RegisterWithParent()
	. = ..()
	if(!ismob(parent)) // no, you still have to go under the shower
		RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_expose_reagent))

/datum/component/irradiated/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT)

/datum/component/irradiated/proc/on_expose_reagent(atom/source, datum/reagent/reagent, reac_volume)
	SIGNAL_HANDLER
	if(istype(reagent, /datum/reagent/medicine/potass_iodide) && reac_volume >= 1)
		qdel(src)

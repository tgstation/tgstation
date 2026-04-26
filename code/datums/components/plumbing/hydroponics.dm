/// Special demand connector that consumes as normal, but redirects water into the magical water space.
/datum/component/plumbing/hydroponics
	demand_connects = SOUTH
	/// Alternate reagents container to buffer incoming water
	var/datum/reagents/water_reagents
	/// Decides if we receive either water or regular reagents
	var/receive_water = FALSE

/datum/component/plumbing/hydroponics/Initialize(ducting_layer)
	. = ..()

	if(!istype(parent, /obj/machinery/hydroponics/constructable))
		return COMPONENT_INCOMPATIBLE

	var/obj/machinery/hydroponics/constructable/hydro_parent = parent

	water_reagents = new(hydro_parent.maxwater)
	water_reagents.my_atom = hydro_parent

/datum/component/plumbing/hydroponics/Destroy()
	QDEL_NULL(water_reagents)
	return ..()

/datum/component/plumbing/hydroponics/recipient_reagents_holder()
	return receive_water ? water_reagents : reagents

/datum/component/plumbing/hydroponics/send_request(dir)
	var/obj/machinery/hydroponics/constructable/hydro_parent = parent

	var/initial_nutri_amount = reagents.total_volume
	if(initial_nutri_amount < reagents.maximum_volume)
		// Well boy howdy, we have no way to tell a supply to not mix the water with everything else,
		// So we'll let it leak in, and move the water over.
		receive_water = FALSE
		process_request(dir = dir, round_robin = FALSE)

		// Move the leaked water from nutrients to... water
		var/leaking_water_amount = reagents.get_reagent_amount(/datum/reagent/water)
		if(leaking_water_amount)
			reagents.trans_to(water_reagents, leaking_water_amount, target_id = /datum/reagent/water)

	// We should only take MACHINE_REAGENT_TRANSFER every tick; this is the remaining amount we can take
	var/remaining_transfer_amount = max(MACHINE_REAGENT_TRANSFER - (reagents.total_volume - initial_nutri_amount), 0)

	// How much extra water we should gather this tick to try to fill the water tray.
	var/extra_water_to_gather = clamp(hydro_parent.maxwater - hydro_parent.waterlevel - water_reagents.total_volume, 0, remaining_transfer_amount)
	if(extra_water_to_gather > 0)
		receive_water = TRUE
		process_request(
			amount = extra_water_to_gather,
			reagent = /datum/reagent/water,
			dir = dir
		)

	// Now transfer all remaining water in that buffer and clear it out.
	var/final_water_amount = water_reagents.total_volume
	if(final_water_amount)
		hydro_parent.adjust_waterlevel(round(final_water_amount))
		// Using a pipe doesn't afford you extra water storage and the baseline behavior for trays is that excess water goes into the shadow realm.
		water_reagents.clear_reagents()

/**
 * Hydroponics plumbing component
 *
 * This will smartly separate water and misc chems in the pipes
 * so that you never drain one while looking for the other.
 *
 * Will not fill hydro tray's nutrients above tray.maxductnutri
 * so that you have room to add chems by hand (pest spray, mutagen, etc)
 *
 * Base code in datums/components/plumbing/_plumbing.dm
 */
/datum/component/plumbing/hydroponics
	demand_connects = SOUTH

/datum/component/plumbing/hydroponics/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()

	if(!istype(parent, /obj/machinery/hydroponics/constructable))
		return COMPONENT_INCOMPATIBLE

	reagents = new(MACHINE_REAGENT_TRANSFER)
	reagents.my_atom = parent
	set_recipient_reagents_holder(reagents)// When we ask others to transfer to us, we mean the temporary buffer.

/datum/component/plumbing/hydroponics/Destroy()
	qdel(reagents)
	return ..()

// Add a check for the water level in determining whether or not to request fluids.
/datum/component/plumbing/hydroponics/process()
	if(!demand_connects || !reagents)
		STOP_PROCESSING(SSplumbing, src)
		return
	var/obj/machinery/hydroponics/constructable/hydro_parent = parent
	if(hydro_parent.reagents.total_volume < hydro_parent.maxductnutri || hydro_parent.waterlevel < hydro_parent.maxwater)
		for(var/dir in GLOB.cardinals)
			if(dir & demand_connects)
				send_request(dir)

/// split_request_across(list/sources,amt,datum/ductnet/net): Request chems selectively from the given sources
/// Returns: The amount transferred
/datum/component/plumbing/hydroponics/proc/split_request_across(list/sources, amt, datum/ductnet/net)
	var/suppliers_left = sources.len
	var/original_volume = reagents.total_volume
	for(var/datum/component/plumbing/give as anything in sources)
		var/current_request = (amt + original_volume - reagents.total_volume) / suppliers_left
		give.transfer_to( src, current_request, null, net, disable_round_robin = TRUE )
		suppliers_left--
	return reagents.total_volume - original_volume

/// send_request(dir): calculate needs for the tray, pass to process_request
/datum/component/plumbing/hydroponics/send_request(dir)
	var/obj/machinery/hydroponics/constructable/hydro_parent = parent
	var/water_desired = clamp(hydro_parent.maxwater - hydro_parent.waterlevel, 0, MACHINE_REAGENT_TRANSFER)
	var/nutri_desired = clamp(hydro_parent.maxductnutri - hydro_parent.reagents.total_volume, 0, MACHINE_REAGENT_TRANSFER)

	process_hydro_request(water_desired, nutri_desired, dir)

/// process_hydro_request(water_amt,nutri_amt,dir): pull water and/or nutrients from duct system
/datum/component/plumbing/hydroponics/proc/process_hydro_request(water_amt, nutri_amt, dir)
	dir = num2text(dir)
	if(!ducts.Find(dir))
		return // Not connected

	var/obj/machinery/hydroponics/constructable/hydro_parent = parent
	var/datum/ductnet/net = ducts[dir]
	var/list/water_suppliers = list()
	var/list/nutri_suppliers = list()

	for(var/datum/component/plumbing/supplier as anything in net.suppliers)
		if(supplier.can_give(1, /datum/reagent/water, net))
			water_suppliers += supplier
			if(!supplier.is_pure_source())
				nutri_suppliers += supplier
		else if(supplier.can_give(1,null,net))
			nutri_suppliers += supplier

	// Reserve some space if we could fill up entirely on water, but want and can get nutrients
	var/total_request = MACHINE_REAGENT_TRANSFER
	if(water_amt && nutri_amt && water_suppliers.len && nutri_suppliers.len)
		if(nutri_suppliers.len)
			water_amt = min(water_amt, MACHINE_REAGENT_TRANSFER * 0.75)

	if(water_suppliers.len && water_amt)
		total_request -= split_request_across( water_suppliers, water_amt, net ) // this may also get chems

	if(nutri_suppliers.len && nutri_amt)
		split_request_across( nutri_suppliers, min(nutri_amt, total_request), net ) // this may also get water

	// finish by transferring to the tray itself
	hydro_parent.adjust_waterlevel( reagents.get_reagent_amount(/datum/reagent/water) )
	reagents.del_reagent( /datum/reagent/water )
	reagents.trans_to( hydro_parent.reagents, reagents.total_volume )
	reagents.clear_reagents()

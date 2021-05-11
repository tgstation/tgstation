//(create dirty dust from clumps)
/**
 * Uses 1 clump to make 2 dirty dusts
 */
/obj/machinery/ore_processing/crusher
	name = "ore crusher"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	var/clump_multiplier = 1
	var/amount_to_process = 5
	var/processing_amount = 0

	var/list/clump_amounts = list(
		/obj/item/stack/process_ore/clump/uranium = 0,
		/obj/item/stack/process_ore/clump/diamond = 0,
		/obj/item/stack/process_ore/clump/titanium = 0,
		/obj/item/stack/process_ore/clump/bluespace_crystal = 0,
		/obj/item/stack/process_ore/clump/iron = 0,
		/obj/item/stack/process_ore/clump/plasma = 0,
		/obj/item/stack/process_ore/clump/gold = 0,
		/obj/item/stack/process_ore/clump/silver = 0
		)

/obj/machinery/ore_processing/crusher/pickup_item(atom/movable/target)
	. = ..()
	if(QDELETED(target))
		return

	if(panel_open || !powered())
		return

	if(istype(target, /obj/item/stack/process_ore/clump))
		var/obj/item/stack/process_ore/clump/store_clump = target
		clump_amounts[target.type] += store_clump.amount
		qdel(target)

/obj/machinery/ore_processing/crusher/process(delta_time)
	if(processing_amount >= amount_to_process)
		return

	if(process_internal())
		use_power(processing_amount * delta_time)

/obj/machinery/ore_processing/crusher/proc/process_internal()
	for(var/obj/item/stack/process_ore/clump/to_process as anything in clump_amounts)
		if(processing_amount >= amount_to_process)
			break
		var/clump_number = clump_amounts[to_process]
		for(var/i in 1 to clump_number)
			if(processing_amount >= amount_to_process)
				break
			clump_amounts[to_process] -= clump_multiplier
			var/obj/item/stack/process_ore/dirty_dust/dirty_to_create = initial(to_process.dirty_type)
			processing_amount += 1
			addtimer(CALLBACK(src, .proc/produce_sheet, dirty_to_create), 0.5 SECONDS)

/obj/machinery/ore_processing/crusher/proc/produce_sheet(dirty_to_create)
	processing_amount -= 1
	new dirty_to_create(get_step(src, output_direction))
	new dirty_to_create(get_step(src, output_direction))

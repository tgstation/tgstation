//TIER 1 (1:1) (create dust from ores and dirty dust)
/**
 * Uses 1 ore to create 1 dust or 1 dirty dusts to make 1 dust
 * 1 ore = 1 dust = 1 sheet
 */
/obj/machinery/ore_processing/enrichment_chamber
	name = "ore enrichment chamber"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	var/ore_multiplier = 1
	var/dirty_dust_multiplier = 1
	var/amount_to_process = 5
	var/processing_amount = 0

	var/list/ore_amounts = list(
		/obj/item/stack/ore/uranium = 0,
		/obj/item/stack/ore/diamond = 0,
		/obj/item/stack/ore/titanium = 0,
		/obj/item/stack/ore/bluespace_crystal = 0,
		/obj/item/stack/ore/iron = 0,
		/obj/item/stack/ore/plasma = 0,
		/obj/item/stack/ore/gold = 0,
		/obj/item/stack/ore/silver = 0
		)

	var/list/dirty_dust_amounts = list(
		/obj/item/stack/process_ore/dirty_dust/uranium = 0,
		/obj/item/stack/process_ore/dirty_dust/diamond = 0,
		/obj/item/stack/process_ore/dirty_dust/titanium = 0,
		/obj/item/stack/process_ore/dirty_dust/bluespace_crystal = 0,
		/obj/item/stack/process_ore/dirty_dust/iron = 0,
		/obj/item/stack/process_ore/dirty_dust/plasma = 0,
		/obj/item/stack/process_ore/dirty_dust/gold = 0,
		/obj/item/stack/process_ore/dirty_dust/silver = 0
		)

/obj/machinery/ore_processing/enrichment_chamber/pickup_item(atom/movable/target)
	. = ..()
	if(QDELETED(target))
		return

	if(panel_open || !powered())
		return

	if(istype(target, /obj/item/stack/ore))
		var/obj/item/stack/ore/store_ore = target
		ore_amounts[target.type] += store_ore.amount
		qdel(target)
	else if(istype(target, /obj/item/stack/process_ore/dirty_dust))
		var/obj/item/stack/process_ore/dirty_dust/store_dust = target
		dirty_dust_amounts[target.type] += store_dust.amount
		qdel(target)

/obj/machinery/ore_processing/enrichment_chamber/process(delta_time)
	if(processing_amount >= amount_to_process)
		return

	if(process_internal())
		use_power(processing_amount * delta_time)

/obj/machinery/ore_processing/enrichment_chamber/proc/process_internal()
	for(var/obj/item/stack/ore/to_process as anything in ore_amounts)
		if(processing_amount >= amount_to_process)
			break
		var/ore_number = ore_amounts[to_process]
		for(var/i in 1 to ore_number)
			if(processing_amount >= amount_to_process)
				break
			ore_amounts[to_process] -= ore_multiplier
			var/obj/item/stack/process_ore/dust/dust_to_create = initial(to_process.dust_type)
			processing_amount += 1
			addtimer(CALLBACK(src, .proc/produce_sheet, dust_to_create), 0.5 SECONDS)

	for(var/obj/item/stack/process_ore/dirty_dust/to_process as anything in dirty_dust_amounts)
		if(processing_amount >= amount_to_process)
			break
		var/dirty_dust_number = dirty_dust_amounts[to_process]
		for(var/i in 1 to dirty_dust_number)
			if(processing_amount >= amount_to_process)
				break
			dirty_dust_amounts[to_process] -= dirty_dust_multiplier
			var/obj/item/stack/process_ore/dust/dust_to_create = initial(to_process.dust_type)
			processing_amount += 1
			addtimer(CALLBACK(src, .proc/produce_sheet, dust_to_create), 0.5 SECONDS)


/obj/machinery/ore_processing/enrichment_chamber/proc/produce_sheet(dust_to_create)
	processing_amount -= 1
	new dust_to_create(get_step(src, output_direction))

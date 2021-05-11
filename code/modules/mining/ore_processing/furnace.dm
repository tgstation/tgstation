//TIER 0 (1:2) (ore directly or dust) (roundstart)
/**
 * Use 2 ores or 1 dust to make 1 sheet
 * 2 ores = 1 sheet
 */
/obj/machinery/ore_processing/furnace
	name = "ore furnace"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	var/ore_multiplier = 2
	var/dust_multiplier = 1
	var/ore_to_smelt = 5
	var/smelted_amount = 0

	var/list/ore_amounts = list(
		/obj/item/stack/ore/uranium = 0,
		/obj/item/stack/ore/diamond = 0,
		/obj/item/stack/ore/titanium = 0,
		/obj/item/stack/ore/bluespace_crystal = 0,
		/obj/item/stack/ore/iron = 0,
		/obj/item/stack/ore/plasma = 0,
		/obj/item/stack/ore/gold = 0,
		/obj/item/stack/ore/silver = 0,
		/obj/item/stack/ore/glass = 0
		)

	var/list/dust_amounts = list(
		/obj/item/stack/process_ore/dust/uranium = 0,
		/obj/item/stack/process_ore/dust/diamond = 0,
		/obj/item/stack/process_ore/dust/titanium = 0,
		/obj/item/stack/process_ore/dust/bluespace_crystal = 0,
		/obj/item/stack/process_ore/dust/iron = 0,
		/obj/item/stack/process_ore/dust/plasma = 0,
		/obj/item/stack/process_ore/dust/gold = 0,
		/obj/item/stack/process_ore/dust/silver = 0
		)

/obj/machinery/ore_processing/furnace/pickup_item(atom/movable/target)
	. = ..()
	if(QDELETED(target))
		return

	if(panel_open || !powered())
		return

	if(istype(target, /obj/item/stack/ore))
		var/obj/item/stack/ore/store_ore = target
		ore_amounts[target.type] += store_ore.amount
		qdel(target)
	else if(istype(target, /obj/item/stack/process_ore/dust))
		var/obj/item/stack/process_ore/dust/store_dust = target
		dust_amounts[target.type] += store_dust.amount
		qdel(target)

/obj/machinery/ore_processing/furnace/process(delta_time)
	if(smelted_amount >= ore_to_smelt)
		return

	if(smelt_internal())
		use_power(smelted_amount * delta_time)

/obj/machinery/ore_processing/furnace/proc/smelt_internal()
	for(var/obj/item/stack/ore/to_smelt as anything in ore_amounts)
		if(smelted_amount >= ore_to_smelt)
			break
		if(ore_amounts[to_smelt] < 2)
			continue
		var/ore_number = (ore_amounts[to_smelt] - (ore_amounts[to_smelt] % 2)) / ore_multiplier
		for(var/i in 1 to ore_number)
			if(smelted_amount >= ore_to_smelt)
				break
			ore_amounts[to_smelt] -= ore_multiplier
			var/obj/item/stack/sheet/mineral/sheet_to_create = initial(to_smelt.refined_type)
			smelted_amount += 1
			addtimer(CALLBACK(src, .proc/produce_sheet, sheet_to_create), 0.5 SECONDS)

	for(var/obj/item/stack/process_ore/dust/to_smelt as anything in dust_amounts)
		if(smelted_amount >= ore_to_smelt)
			break
		var/dust_number = dust_amounts[to_smelt]
		for(var/i in 1 to dust_number)
			if(smelted_amount >= ore_to_smelt)
				break
			dust_amounts[to_smelt] -= dust_multiplier
			var/obj/item/stack/sheet/mineral/sheet_to_create = initial(to_smelt.refined_type)
			smelted_amount += 1
			addtimer(CALLBACK(src, .proc/produce_sheet, sheet_to_create), 0.5 SECONDS)


/obj/machinery/ore_processing/furnace/proc/produce_sheet(sheet_to_create)
	smelted_amount -= 1
	new sheet_to_create(get_step(src, output_direction))

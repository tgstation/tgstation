//TIER 3 (4:1) (create shards from ores)
/**
 * uses 1 ore to create 1 shard
 * 1 ore = 1 shard = 2 clumps = 4 dirty dusts = 4 dusts = 4 sheets
 */
/obj/machinery/ore_processing/chemical_injection_chamber
	name = "chemical injection chamber"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	var/ore_multiplier = 1
	var/amount_to_process = 5
	var/processing_amount = 0

	var/datum/component/plumbing/simple_demand/plumbing_connection

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

/obj/machinery/ore_processing/chemical_injection_chamber/Initialize()
	create_reagents(100, OPENCONTAINER)
	. = ..()
	plumbing_connection = AddComponent(/datum/component/plumbing/simple_demand)
	plumbing_connection.demand_connects = turn(dir, 90)

/obj/machinery/ore_processing/chemical_injection_chamber/attackby(obj/item/tool, mob/living/user, params)
	if(!active)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
			return
	if(default_change_direction_wrench(user, tool))
		input_direction = turn(dir, 180)
		plumbing_connection.demand_connects = turn(dir, 90)
		output_direction = dir
		return
	if(default_deconstruction_crowbar(tool))
		return

/obj/machinery/ore_processing/chemical_injection_chamber/pickup_item(atom/movable/target)
	. = ..()
	if(QDELETED(target))
		return

	if(panel_open || !powered())
		return

	if(istype(target, /obj/item/stack/ore))
		var/obj/item/stack/ore/store_ore = target
		ore_amounts[target.type] += store_ore.amount
		qdel(target)

/obj/machinery/ore_processing/chemical_injection_chamber/process(delta_time)
	if(!reagents.has_reagent(/datum/reagent/toxin/acid, 15))
		return

	if(processing_amount >= amount_to_process)
		return

	if(process_internal())
		use_power(processing_amount * delta_time)

/obj/machinery/ore_processing/chemical_injection_chamber/proc/process_internal()
	for(var/obj/item/stack/ore/to_process as anything in ore_amounts)
		if(processing_amount >= amount_to_process)
			break
		var/ore_number = ore_amounts[to_process]
		for(var/i in 1 to ore_number)
			if(processing_amount >= amount_to_process)
				break
			ore_amounts[to_process] -= ore_multiplier
			var/obj/item/stack/process_ore/shard/shard_to_create = initial(to_process.shard_type)
			processing_amount += 1
			reagents.remove_reagent(/datum/reagent/toxin/acid, 6)
			addtimer(CALLBACK(src, .proc/produce_sheet, shard_to_create), 0.5 SECONDS)

/obj/machinery/ore_processing/chemical_injection_chamber/proc/produce_sheet(shard_to_create)
	processing_amount -= 1
	new shard_to_create(get_step(src, output_direction))

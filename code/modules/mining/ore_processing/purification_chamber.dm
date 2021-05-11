//TIER 2 (2:1) (create clumps from ores and shards)
/**
 * uses 1 ore to make 1 clumps or 1 shard to make 2 clumps
 * 1 ore = 1 clump = 2 dirty dusts = 2 dusts = 2 sheets
 */
/obj/machinery/atmospherics/components/unary/purification_chamber
	name = "ore purification chamber"
	icon = 'icons/obj/atmospherics/components/thermomachine.dmi'
	icon_state = "freezer"
	density = TRUE
	anchored = TRUE

	var/input_direction
	var/output_direction
	var/active = FALSE

	var/obj/machinery/conveyor/auto/no_deconstruct/base_conv

	var/ore_multiplier = 1
	var/shard_multiplier = 1
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

	var/list/shard_amounts = list(
		/obj/item/stack/process_ore/shard/uranium = 0,
		/obj/item/stack/process_ore/shard/diamond = 0,
		/obj/item/stack/process_ore/shard/titanium = 0,
		/obj/item/stack/process_ore/shard/bluespace_crystal = 0,
		/obj/item/stack/process_ore/shard/iron = 0,
		/obj/item/stack/process_ore/shard/plasma = 0,
		/obj/item/stack/process_ore/shard/gold = 0,
		/obj/item/stack/process_ore/shard/silver = 0
		)

/obj/machinery/atmospherics/components/unary/purification_chamber/Initialize()
	. = ..()
	input_direction = turn(dir, 180)
	output_direction = dir
	base_conv = new/obj/machinery/conveyor/auto/no_deconstruct(get_step(loc, input_direction), dir)

/obj/machinery/atmospherics/components/unary/purification_chamber/SetInitDirections()
	initialize_directions = turn(dir, 90)

/obj/machinery/atmospherics/components/unary/purification_chamber/Bumped(atom/movable/item)
	. = ..()
	if(get_dir(src, item) == input_direction && istype(item, /obj/item/stack))
		pickup_item(item)

/obj/machinery/atmospherics/components/unary/purification_chamber/attackby(obj/item/tool, mob/living/user, params)
	if(!active)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
			return
	if(default_change_direction_wrench(user, tool))
		QDEL_NULL(base_conv)
		base_conv = new/obj/machinery/conveyor/auto/no_deconstruct(get_step(loc, input_direction), dir)
		input_direction = turn(dir, 180)
		output_direction = dir
		return
	if(default_deconstruction_crowbar(tool))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/purification_chamber/default_change_direction_wrench(mob/user, obj/item/I)
	. = ..()
	if(!.)
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node1 = nodes[1]
	if(node1)
		if(src in node1.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node1.disconnect(src)
		nodes[1] = null

	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node1 = nodes[1]
	if(node1)
		node1.atmosinit()
		node1.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE

/obj/machinery/atmospherics/components/unary/purification_chamber/proc/pickup_item(atom/movable/target)
	if(QDELETED(target))
		return

	if(panel_open || !powered())
		return

	if(istype(target, /obj/item/stack/ore))
		var/obj/item/stack/ore/store_ore = target
		ore_amounts[target.type] += store_ore.amount
		qdel(target)
	else if(istype(target, /obj/item/stack/process_ore/shard))
		var/obj/item/stack/process_ore/shard/store_shard = target
		shard_amounts[target.type] += store_shard.amount
		qdel(target)

/obj/machinery/atmospherics/components/unary/purification_chamber/process_atmos()

	if(!nodes[1] || !airs[1].total_moles() || !check_gas())
		return

	if(processing_amount >= amount_to_process)
		return

	if(process_internal())
		use_power(processing_amount)

/obj/machinery/atmospherics/components/unary/purification_chamber/proc/check_gas()
	var/datum/gas_mixture/input = airs[1]
	return input.has_gas(/datum/gas/plasma, 10)

/obj/machinery/atmospherics/components/unary/purification_chamber/proc/process_internal()
	var/datum/gas_mixture/input = airs[1]
	for(var/obj/item/stack/ore/to_process as anything in ore_amounts)
		if(processing_amount >= amount_to_process)
			break
		var/ore_number = ore_amounts[to_process]
		for(var/i in 1 to ore_number)
			if(processing_amount >= amount_to_process)
				break
			ore_amounts[to_process] -= ore_multiplier
			var/obj/item/stack/process_ore/clump/clump_to_create = initial(to_process.clump_type)
			processing_amount += 1
			input.gases[/datum/gas/plasma][MOLES] -= 2.5
			addtimer(CALLBACK(src, .proc/produce_sheet, clump_to_create), 0.5 SECONDS)

	for(var/obj/item/stack/process_ore/shard/to_process as anything in shard_amounts)
		if(processing_amount >= amount_to_process)
			break
		var/shard_number = shard_amounts[to_process]
		for(var/i in 1 to shard_number)
			if(processing_amount >= amount_to_process)
				break
			shard_amounts[to_process] -= shard_multiplier
			var/obj/item/stack/process_ore/clump/clump_to_create = initial(to_process.clump_type)
			processing_amount += 1
			input.gases[/datum/gas/plasma][MOLES] -= 2.5
			addtimer(CALLBACK(src, .proc/produce_sheet, clump_to_create, 2), 0.5 SECONDS)


/obj/machinery/atmospherics/components/unary/purification_chamber/proc/produce_sheet(clump_to_create, amount = 1)
	processing_amount -= 1
	for(var/i in 1 to amount)
		new clump_to_create(get_step(src, output_direction))

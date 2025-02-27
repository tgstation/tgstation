#define MINERALS_PER_BOULDER 3

/obj/machinery/shuttle_ore_scoop
	name = "shuttle ore scoop"
	desc = "A large manipulator scoop that extends below the shuttle. Robotic armatures sort through and collect usable \
		resources from the steady flow of junk that passes the shuttle by as it flies. Collected materials will be dumped \
		through what you are looking at now, the output hatch of the machine."
	icon = 'modular_doppler/colony_fabricator/icons/tiles_item.dmi'
	icon_state = "colony_grey_texture"
	density = FALSE
	max_integrity = 250
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 20 // 20 KILOWATTS
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/shuttle_ore_scoop
	/// Is the shuttle we're on currently in flight?
	var/flying = FALSE
	/// Keeps track of the callback timer to make sure we don't have more than one
	var/callback_tracker
	/// Weighted list of the ores we can spawn
	var/list/mineral_breakdown = list(
		/datum/material/iron = 1,
		/datum/material/glass = 1,
		/datum/material/plasma = 1,
		/datum/material/titanium = 1,
		/datum/material/silver = 1,
		/datum/material/gold = 1,
		/datum/material/diamond = 1,
		/datum/material/uranium = 1,
		/datum/material/bluespace = 1,
		/datum/material/plastic = 1,
	)
	var/current_boulder_size = BOULDER_SIZE_SMALL
	var/list/boulder_icon_states = list(
		"boulder",
		"rock",
		"stone",
	)
	/// The max number of boulders on top of this thing
	var/maximum_boulder_stockpile = 1
	/// How long between production of new boulders should we wait
	var/boulder_delay = 1 MINUTES

/obj/item/circuitboard/machine/shuttle_ore_scoop
	name = "Shuttle Ore Scoop"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/shuttle_ore_scoop
	req_components = list(
		/datum/stock_part/servo = 2,
		/datum/stock_part/matter_bin = 1,
		/datum/stock_part/scanning_module = 1,
	)

/datum/techweb_node/mining/New()
	design_ids += list(
		"shuttle_ore_scoop",
	)
	return ..()

/datum/design/board/shuttle_ore_scoop
	name = "Shuttle Ore Scoop"
	desc = "The circuit board for a shuttle ore scoop."
	id = "shuttle_ore_scoop"
	build_path = /obj/item/circuitboard/machine/shuttle_ore_scoop
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/obj/machinery/shuttle_ore_scoop/RefreshParts()
	. = ..()
	boulder_delay = initial(boulder_delay)
	maximum_boulder_stockpile = initial(maximum_boulder_stockpile)
	current_boulder_size = initial(current_boulder_size)
	var/servo_tier_combined = 0
	for(var/datum/stock_part/servo/servo_part in component_parts)
		servo_tier_combined += servo_part.tier
	if(servo_tier_combined > 2)
		boulder_delay -= ((2.5 SECONDS) * (servo_tier_combined - 2)) // 15 sec reduction at max level just trust
	for(var/datum/stock_part/matter_bin/bin_part in component_parts)
		maximum_boulder_stockpile += (bin_part.tier - 1)
	for(var/datum/stock_part/scanning_module/scanner_part in component_parts)
		if(scanner_part.tier >= 2)
			current_boulder_size = BOULDER_SIZE_MEDIUM
		if(scanner_part.tier >= 4)
			current_boulder_size = BOULDER_SIZE_LARGE

/obj/machinery/shuttle_ore_scoop/examine(mob/user)
	. = ..()
	. += span_notice("The scoop will only function on <b>shuttles</b> that are <b>actively flying</b>.")
	if(flying)
		. += span_notice("You can hear the arms moving around down there, all you need to do now is wait.")

/// Makes a boulder of random size and material composition based off the set variables
/obj/machinery/shuttle_ore_scoop/proc/produce_boulder()
	if(!flying)
		return
	var/local_vent_count = 0
	for(var/obj/item/boulder/old_rock in loc)
		local_vent_count++
	if(local_vent_count >= maximum_boulder_stockpile)
		if(callback_tracker)
			deltimer(callback_tracker)
		callback_tracker = addtimer(CALLBACK(src, PROC_REF(produce_boulder)), boulder_delay, TIMER_DELETE_ME | TIMER_STOPPABLE,)
		return
	// How It's Made: Boulders
	var/obj/item/boulder/new_rock
	new_rock = new /obj/item/boulder(loc)
	playsound(src, 'sound/machines/mail_sort.ogg', 30, TRUE)
	Shake(duration = 1.5 SECONDS)
	// Decoration
	var/list/mats_list = list()
	for(var/iteration in 1 to MINERALS_PER_BOULDER)
		var/datum/material/material = pick_weight(mineral_breakdown)
		mats_list[material] += ore_quantity_function(iteration)
	new_rock.set_custom_materials(mats_list)
	// Size and durability
	new_rock.boulder_size = current_boulder_size
	new_rock.durability = rand(2, new_rock.boulder_size)
	new_rock.boulder_string = pick(boulder_icon_states)
	new_rock.update_appearance(UPDATE_ICON_STATE)
	// Do it all over again
	if(callback_tracker)
		deltimer(callback_tracker)
	callback_tracker = addtimer(CALLBACK(src, PROC_REF(produce_boulder)), boulder_delay, TIMER_DELETE_ME | TIMER_STOPPABLE,)

/**
 * Returns the quantity of mineral sheets in each ore vent's boulder contents roll.
 * First roll can produce the most ore, with subsequent rolls scaling lower logarithmically.
 * Inversely scales with ore_floor, so that the first roll is the largest, and subsequent rolls are smaller.
 * (1 -> from 16 to 7 sheets of materials, and 3 -> from 8 to 6 sheets of materials on a small vent)
 * This also means a large boulder can highroll a boulder with a full stack of 50 sheets of material.
 * @params ore_floor The number of minerals already rolled. Used to scale the logarithmic function.
 */
/obj/machinery/shuttle_ore_scoop/proc/ore_quantity_function(ore_floor)
	return SHEET_MATERIAL_AMOUNT * round(current_boulder_size * (log(rand(1 + ore_floor, 4 + ore_floor)) ** -1))

/obj/machinery/shuttle_ore_scoop/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(moving_dock.mode == SHUTTLE_CALL)
		if(callback_tracker)
			return
		flying = TRUE
		callback_tracker = addtimer(CALLBACK(src, PROC_REF(produce_boulder)), boulder_delay, TIMER_DELETE_ME | TIMER_STOPPABLE,)
		return
	else
		flying = FALSE
		if(callback_tracker)
			deltimer(callback_tracker)

#undef MINERALS_PER_BOULDER

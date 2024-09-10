/obj/machinery/cell_charger_multi
	name = "mounted multi-cell charging rack"
	desc = "The innovative technology of a cell charging rack, but mounted neatly on a wall out of the way!"
	icon = 'modular_doppler/colony_fabricator/icons/cell_charger.dmi'
	icon_state = "wall_charger"
	base_icon_state = "wall_charger"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = AREA_USAGE_EQUIP
	circuit = null
	/// The list of batteries we are gonna charge!
	var/list/charging_batteries = list()
	/// Number of concurrent batteries that can be charged
	var/max_batteries = 3
	/// The base charge rate when spawned
	var/charge_rate = STANDARD_CELL_RATE * 3
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/wallframe/cell_charger_multi

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/cell_charger_multi, 29)

/obj/machinery/cell_charger_multi/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/cell_charger_multi/update_overlays()
	. = ..()

	if(!charging_batteries.len)
		return

	for(var/i = charging_batteries.len, i >= 1, i--)
		var/obj/item/stock_parts/power_store/cell/charging = charging_batteries[i]
		var/newlevel = round(charging.percent() * 4 / 100)
		var/mutable_appearance/charge_overlay = mutable_appearance(icon, "[base_icon_state]-o[newlevel]")
		var/mutable_appearance/cell_overlay = mutable_appearance(icon, "[base_icon_state]-cell")
		charge_overlay.pixel_x = 5 * (i - 1)
		cell_overlay.pixel_x = 5 * (i - 1)
		. += new /mutable_appearance(charge_overlay)
		. += new /mutable_appearance(cell_overlay)

/obj/machinery/cell_charger_multi/attack_hand_secondary(mob/user, list/modifiers)
	if(!can_interact(user) || !charging_batteries.len)
		return
	to_chat(user, span_notice("You press the quick release as all the cells pop out!"))
	for(var/i in charging_batteries)
		removecell()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/cell_charger_multi/examine(mob/user)
	. = ..()
	if(!charging_batteries.len)
		. += "There are no cells in [src]."
	else
		. += "There are [charging_batteries.len] cells in [src]."
		for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
			. += "There's [charging] cell in the charger, current charge: [round(charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Charging power: <b>[display_power(charge_rate, convert = FALSE)]</b> per cell.")
	. += span_notice("Right click it to remove all the cells at once!")

/obj/machinery/cell_charger_multi/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	user.balloon_alert(user, "deconstructing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return


/obj/machinery/cell_charger_multi/attackby(obj/item/tool, mob/user, params)
	if(istype(tool, /obj/item/stock_parts/power_store/cell) && !panel_open)
		if(machine_stat & BROKEN)
			to_chat(user, span_warning("[src] is broken!"))
			return
		if(!anchored)
			to_chat(user, span_warning("[src] isn't attached to the ground!"))
			return
		var/obj/item/stock_parts/power_store/cell/inserting_cell = tool
		if(inserting_cell.chargerate <= 0)
			to_chat(user, span_warning("[inserting_cell] cannot be recharged!"))
			return
		if(length(charging_batteries) >= max_batteries)
			to_chat(user, span_warning("[src] is full, and cannot hold anymore cells!"))
			return
		else
			var/area/current_area = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(current_area))
				return
			if(current_area.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, span_warning("[src] blinks red as you try to insert the cell!"))
				return
			if(!user.transferItemToLoc(tool,src))
				return

			charging_batteries += tool
			user.visible_message(span_notice("[user] inserts a cell into [src]."), span_notice("You insert a cell into [src]."))
			update_appearance()
	else
		if(!charging_batteries.len && default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
			return
		if(default_deconstruction_crowbar(tool))
			return
		if(!charging_batteries.len && default_unfasten_wrench(user, tool))
			return
		return ..()

/obj/machinery/cell_charger_multi/process(seconds_per_tick)
	if(!charging_batteries.len || !anchored || (machine_stat & (BROKEN|NOPOWER)))
		return

	// create a charging queue, we only want cells that require charging to use the power budget
	var/list/charging_queue
	for(var/obj/item/stock_parts/power_store/cell/battery_slot in charging_batteries)
		if(battery_slot.percent() >= 100)
			continue
		LAZYADD(charging_queue, battery_slot)

	if(!LAZYLEN(charging_queue))
		return

	//use a small bit for the charger itself, but power usage scales up with the part tier
	use_energy(charge_rate / length(charging_queue) * seconds_per_tick * 0.01)

	for(var/obj/item/stock_parts/power_store/cell/charging_cell in charging_queue)
		charge_cell(charge_rate * seconds_per_tick, charging_cell)

	LAZYNULL(charging_queue)
	update_appearance()

/obj/machinery/cell_charger_multi/attack_tk(mob/user)
	if(!charging_batteries.len)
		return

	to_chat(user, span_notice("You telekinetically remove [removecell(user)] from [src]."))

	return COMPONENT_CANCEL_ATTACK_CHAIN


/obj/machinery/cell_charger_multi/RefreshParts()
	. = ..()
	var/tier_total
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		tier_total += capacitor.tier
	charge_rate = tier_total * (initial(charge_rate) / 6)

/obj/machinery/cell_charger_multi/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_CONTENTS)
		return

	for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
		charging.emp_act(severity)

/obj/machinery/cell_charger_multi/on_deconstruction(disassembled)
	for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
		charging.forceMove(drop_location())
	charging_batteries = null
	return ..()


/obj/machinery/cell_charger_multi/attack_ai(mob/user)
	return

/obj/machinery/cell_charger_multi/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/obj/item/stock_parts/power_store/cell/charging = removecell(user)

	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message(span_notice("[user] removes [charging] from [src]."), span_notice("You remove [charging] from [src]."))

/obj/machinery/cell_charger_multi/proc/removecell(mob/user)
	if(!charging_batteries.len)
		return FALSE
	var/obj/item/stock_parts/power_store/cell/charging
	if(charging_batteries.len > 1 && user)
		var/list/buttons = list()
		for(var/obj/item/stock_parts/power_store/cell/battery in charging_batteries)
			buttons["[battery.name] ([round(battery.percent(), 1)]%)"] = battery
		var/cell_name = tgui_input_list(user, "Please choose what cell you'd like to remove.", "Remove a cell", buttons)
		charging = buttons[cell_name]
	else
		charging = charging_batteries[1]
	if(!charging)
		return FALSE
	charging.forceMove(drop_location())
	charging.update_appearance()
	charging_batteries -= charging
	update_appearance()
	return charging

/obj/machinery/cell_charger_multi/Destroy()
	for(var/obj/item/stock_parts/power_store/cell/charging in charging_batteries)
		QDEL_NULL(charging)
	charging_batteries = null
	return ..()

// formerly NO_DECONSTRUCTION
/obj/machinery/cell_charger_multi/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/cell_charger_multi/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/cell_charger_multi/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/cell_charger_multi/on_deconstruction(disassembled)
	if(disassembled)
		new repacked_type(drop_location())

/obj/machinery/cell_charger_multi/RefreshParts()
	. = ..()
	charge_rate = STANDARD_CELL_RATE * 3 // Nuh uh!

// Item for creating the arc furnace or carrying it around

/obj/item/wallframe/cell_charger_multi
	name = "unmounted wall multi-cell charging rack"
	desc = "The innovative technology of a cell charging rack, but able to be mounted neatly on a wall out of the way!"
	icon = 'modular_doppler/colony_fabricator/icons/packed_machines.dmi'
	icon_state = "cell_charger_packed"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/cell_charger_multi
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
	)

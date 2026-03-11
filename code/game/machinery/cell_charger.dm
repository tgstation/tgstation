/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/machines/cell_charger.dmi'
	icon_state = "ccharger"
	power_channel = AREA_USAGE_EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger
	pass_flags = PASSTABLE
	var/obj/item/stock_parts/power_store/cell/charging = null
	var/charge_rate = 0.25 * STANDARD_CELL_RATE

/obj/machinery/cell_charger/update_overlays()
	. = ..()

	if(!charging)
		return

	if(!(machine_stat & (BROKEN|NOPOWER)))
		var/newlevel = round(charging.percent() * 4 / 100)
		. += "ccharger-o[newlevel]"
	. += image(charging.icon, charging.icon_state)
	if(charging.grown_battery)
		. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "grown_wires")
	. += "ccharger-[charging.connector_type]-on"
	if((charging.charge > 0.01) && charging.charge_light_type)
		. += mutable_appearance('icons/obj/machines/cell_charger.dmi', "cell-[charging.charge_light_type]-o[(charging.percent() >= 99.5) ? 2 : 1]")

/obj/machinery/cell_charger/examine(mob/user)
	. = ..()
	. += "There's [charging ? "\a [charging]" : "no cell"] in the charger."
	if(charging)
		. += "Current charge: [round(charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Charging power: <b>[display_power(charge_rate, convert = FALSE)]</b>.")

/obj/machinery/cell_charger/wrench_act(mob/living/user, obj/item/tool)
	if(charging)
		return NONE
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cell_charger/screwdriver_act(mob/living/user, obj/item/tool)
	return charging ? NONE : default_deconstruction_screwdriver(user, tool)

/obj/machinery/cell_charger/crowbar_act(mob/living/user, obj/item/tool)
	return charging ? NONE : default_deconstruction_crowbar(tool)

/obj/machinery/cell_charger/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stock_parts/power_store/cell) || panel_open)
		return NONE

	if(machine_stat & BROKEN)
		to_chat(user, span_warning("[src] is broken!"))
		return ITEM_INTERACT_BLOCKING
	if(!anchored)
		to_chat(user, span_warning("[src] isn't attached to the ground!"))
		return ITEM_INTERACT_BLOCKING
	if(charging)
		to_chat(user, span_warning("There is already a cell in the charger!"))
		return ITEM_INTERACT_BLOCKING

	var/area/charge_area = get_area(src)
	if(!isarea(charge_area))
		return ITEM_INTERACT_BLOCKING
	if(!charge_area.power_equip) // There's no APC in this area, don't try to cheat power!
		to_chat(user, span_warning("[src] blinks red as you try to insert the cell!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING

	charging = tool
	user.visible_message(
		span_notice("[user] inserts a cell into [src]."),
		span_notice("You insert a cell into [src]."),
	)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/cell_charger/on_deconstruction(disassembled)
	charging?.forceMove(drop_location())

/obj/machinery/cell_charger/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == charging)
		charging = null

/obj/machinery/cell_charger/Destroy()
	QDEL_NULL(charging)
	return ..()

/obj/machinery/cell_charger/proc/removecell(new_loc)
	. = charging
	charging.update_appearance()
	charging.forceMove(new_loc)
	charging = null
	update_appearance()

/obj/machinery/cell_charger/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !charging)
		return

	charging.add_fingerprint(user)
	user.visible_message(span_notice("[user] removes [charging] from [src]."), span_notice("You remove [charging] from [src]."))
	user.put_in_hands(removecell(drop_location()))

/obj/machinery/cell_charger/attack_tk(mob/user)
	if(!charging)
		return

	to_chat(user, span_notice("You telekinetically remove [charging] from [src]."))
	removecell(drop_location())
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/machinery/cell_charger/attack_ai(mob/user)
	return

/obj/machinery/cell_charger/emp_act(severity)
	. = ..()

	if(machine_stat & (BROKEN|NOPOWER) || . & EMP_PROTECT_CONTENTS)
		return

	if(charging)
		charging.emp_act(severity)

/obj/machinery/cell_charger/RefreshParts()
	. = ..()
	charge_rate = 0.25 * STANDARD_CELL_RATE
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		charge_rate *= capacitor.tier

/obj/machinery/cell_charger/process(seconds_per_tick)
	if(!charging || charging.percent() >= 100 || !anchored || !is_operational)
		return

	var/main_draw = charge_rate * seconds_per_tick
	if(!main_draw)
		return

	//charge cell, account for heat loss from work done
	var/charge_given = charge_cell(main_draw, charging, grid_only = TRUE)
	if(charge_given)
		use_energy((charge_given + active_power_usage) * 0.01)

	update_appearance()

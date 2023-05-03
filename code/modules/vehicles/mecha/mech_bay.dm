/**
 * # Mech Bay Power Port
 *
 * Machinery that charges Exosuits primarily. The associated computer will display basic information as well.
 * Also charges machines with a cell (except those under the machery/power tree), but prioritizes exosuits.
 */

/obj/machinery/mech_bay_recharge_port
	name = "mech bay power port"
	desc = "This port recharges a mech's internal power cell."
	density = TRUE
	dir = EAST
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	circuit = /obj/item/circuitboard/machine/mech_recharger
	///Weakref to currently recharging machine on our recharging_turf
	var/datum/weakref/recharging_machine_ref
	///Weakref to the above's cell
	var/datum/weakref/recharging_powercell_ref
	///Ref to charge console for seeing charge for this port, cyclical reference
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	///Power unit per second to charge by
	var/recharge_power = 25
	///turf that will be checked when a mech wants to charge. directly one turf in the direction it is facing
	var/turf/recharging_turf

/obj/machinery/mech_bay_recharge_port/Initialize(mapload)
	. = ..()
	recharging_turf = get_step(loc, dir)

	if(!mapload)
		return

	var/area/my_area = get_area(src)
	if(!(my_area.type in GLOB.the_station_areas))
		return

	var/area_name = get_area_name(src, format_text = TRUE)
	if(area_name in GLOB.roundstart_station_mechcharger_areas)
		return
	GLOB.roundstart_station_mechcharger_areas += area_name

/obj/machinery/mech_bay_recharge_port/Destroy()
	if (recharge_console?.recharge_port == src)
		recharge_console.recharge_port = null
	return ..()

/obj/machinery/mech_bay_recharge_port/setDir(new_dir)
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	. = ..()
	var/total_rating = 0
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		total_rating += capacitor.tier
	recharge_power = total_rating * 12.5

/obj/machinery/mech_bay_recharge_port/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharge power <b>[siunit(recharge_power, "W", 1)]</b>.")

/obj/machinery/mech_bay_recharge_port/power_change()
	if(!(machine_stat & NOPOWER))
		begin_processing()
	return ..()


/**
 * Attempts to "connect" to a machine at the recharge location, prioritizing mechs.
 *
 * Does not connect to objects in the /obj/machinery/power tree. Starts processing if
 * connection is valid.
 */
/obj/machinery/mech_bay_recharge_port/proc/try_connect()
	if(machine_stat & NOPOWER || !recharge_console)
		return
	var/obj/recharging_machine = recharging_machine_ref?.resolve()
	var/obj/item/stock_parts/cell/electron_cache = recharging_powercell_ref?.resolve()

	if(recharging_machine?.loc != recharging_turf)
		recharging_machine = null
		recharging_machine_ref = null

	if(electron_cache?.loc != recharging_machine?.loc)
		electron_cache = null
		recharging_powercell_ref = null

	if(!recharging_machine)
		electron_cache = null
		var/obj/vehicle/sealed/mecha/exosuit = locate(/obj/vehicle/sealed/mecha) in recharging_turf
		if(exosuit)
			recharging_machine = exosuit
			recharging_machine_ref = WEAKREF(recharging_machine)
			electron_cache = exosuit.cell
			recharging_powercell_ref = WEAKREF(electron_cache)
			recharge_console.update_appearance()
		else
			for(var/obj/machinery/machine in recharging_turf)
				if(istype(machine, /obj/machinery/power))
					continue //nice try
				electron_cache = locate(/obj/item/stock_parts/cell) in machine.contents
				if(electron_cache)
					recharging_machine = machine
					recharging_machine_ref = WEAKREF(recharging_machine)
					recharging_powercell_ref = WEAKREF(electron_cache)
					recharge_console.update_appearance()
					break

	if(recharging_machine && electron_cache)
		begin_processing()

/obj/machinery/mech_bay_recharge_port/process(seconds_per_tick)
	if(machine_stat & NOPOWER || !recharge_console)
		end_processing()
		return

	var/obj/recharging_machine = recharging_machine_ref?.resolve()
	var/obj/item/stock_parts/cell/electron_cache = recharging_powercell_ref?.resolve()

	if(!recharging_machine)
		end_processing()
		return

	if(recharging_machine.loc !=  recharging_turf)
		recharging_machine = null
		recharging_machine_ref = null
		electron_cache = null
		recharging_powercell_ref = null
		end_processing()
		return

	if(!electron_cache || (electron_cache.loc != recharging_machine))
		electron_cache = null
		recharging_powercell_ref = null
		return

	if(electron_cache.charge < electron_cache.maxcharge)
		var/delta = min(recharge_power * seconds_per_tick, electron_cache.maxcharge - electron_cache.charge)
		electron_cache.give(delta)
		use_power(delta + active_power_usage)
	recharge_console.update_appearance()

/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return

	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	desc = "Displays the status of mechs connected to the recharge station."
	icon_screen = "recharge_comp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/mech_bay_power_console
	light_color = LIGHT_COLOR_PINK
	///Ref to charge port fwe are viewing data for, cyclical reference
	var/obj/machinery/mech_bay_recharge_port/recharge_port

/obj/machinery/computer/mech_bay_power_console/Initialize(mapload)
	. = ..()
	reconnect()

/obj/machinery/computer/mech_bay_power_console/Destroy()
	if (recharge_port?.recharge_console == src)
		recharge_port.recharge_console = null
	return ..()

/obj/machinery/computer/mech_bay_power_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechBayPowerConsole", name)
		ui.open()

/obj/machinery/computer/mech_bay_power_console/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("reconnect")
			reconnect()
			. = TRUE
			update_appearance()

/obj/machinery/computer/mech_bay_power_console/ui_data(mob/user)
	var/list/data = list()
	if(QDELETED(recharge_port))
		return data

	data["recharge_port"] = list("mech" = null)

	var/obj/recharging_machine = recharge_port?.recharging_machine_ref?.resolve()
	if(!recharging_machine)
		return data

	var/obj/item/stock_parts/cell/electron_cache = recharge_port?.recharging_powercell_ref?.resolve()
	var/obj/vehicle/sealed/mecha/mech = recharging_machine
	var/list/mechdata = list()
	if(istype(mech))
		mechdata["health"] = mech.get_integrity()
		mechdata["maxhealth"] = mech.max_integrity
		mechdata["name"] = mech.name
	else
		mechdata["health"] = 1
		mechdata["maxhealth"] = 1
		mechdata["name"] = "Generic Powered Device"

	data["recharge_port"]["mech"] = list("health" = mechdata["health"], "maxhealth" = mechdata["maxhealth"], "cell" = null, "name" = mechdata["name"],)

	if(QDELETED(electron_cache))
		return data
	data["recharge_port"]["mech"]["cell"] = list(
	"charge" = electron_cache.charge,
	"maxcharge" = electron_cache.maxcharge
	)
	return data

///Checks for nearby recharge ports to link to
/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		recharge_port.try_connect()
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port)
		for(var/direction in GLOB.cardinals)
			var/turf/target = get_step(src, direction)
			target = get_step(target, direction)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in target
			if(recharge_port)
				break
	if(!recharge_port)
		return
	if(!recharge_port.recharge_console)
		recharge_port.recharge_console = src
		recharge_port.try_connect()
	else
		recharge_port = null

/obj/machinery/computer/mech_bay_power_console/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	var/obj/vehicle/sealed/mecha/recharging_machine = recharge_port?.recharging_machine_ref?.resolve()

	if(!recharging_machine?.cell)
		return
	if(recharging_machine.cell.charge >= recharging_machine.cell.maxcharge)
		return
	. += "recharge_comp_on"

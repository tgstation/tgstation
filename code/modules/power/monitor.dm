//modular computer program version is located in code\modules\modular_computers\file_system\programs\powermonitor.dm, /datum/computer_file/program/power_monitor

/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "It monitors power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	light_color = LIGHT_COLOR_DIM_YELLOW
	use_power = ACTIVE_POWER_USE
	circuit = /obj/item/circuitboard/computer/powermonitor

	var/datum/weakref/attached_wire_ref
	var/datum/weakref/local_apc_ref

	var/list/history = list()
	var/record_size = 60
	var/record_interval = 50
	var/next_record = 0

/obj/machinery/computer/monitor/Initialize(mapload)
	. = ..()
	//Add to the late process queue to record the accurate power usage data
	SSmachines.processing_late += src
	search()
	history["supply"] = list()
	history["demand"] = list()

/obj/machinery/computer/monitor/process_late()
	if(!get_powernet())
		update_use_power(IDLE_POWER_USE)
		search()
	else
		update_use_power(ACTIVE_POWER_USE)
		record()

/obj/machinery/computer/monitor/proc/search() //keep in sync with /obj/machinery/computer/monitor's version
	var/turf/T = get_turf(src)
	attached_wire_ref = WEAKREF(locate(/obj/structure/cable) in T)
	if(attached_wire_ref)
		return
	var/area/A = get_area(src) //if the computer isn't directly connected to a wire, attempt to find the APC powering it to pull it's powernet instead
	if(!A)
		return
	var/obj/machinery/power/apc/local_apc = A.apc
	if(!local_apc)
		return
	if(!local_apc.terminal) //this really shouldn't happen without badminnery.
		local_apc = null
	local_apc_ref = WEAKREF(local_apc)

/obj/machinery/computer/monitor/proc/get_powernet() //keep in sync with /datum/computer_file/program/power_monitor's version //np
	var/obj/structure/cable/attached_wire = attached_wire_ref?.resolve()
	var/obj/machinery/power/apc/local_apc = local_apc_ref?.resolve()
	if(attached_wire || (local_apc?.terminal))
		return attached_wire ? attached_wire.powernet : local_apc.terminal.powernet
	return FALSE

/obj/machinery/computer/monitor/proc/record() //keep in sync with /datum/computer_file/program/power_monitor's version
	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/datum/powernet/connected_powernet = get_powernet()

		var/list/supply = history["supply"]
		if(connected_powernet)
			supply += energy_to_power(connected_powernet.avail)
		if(supply.len > record_size)
			supply.Cut(1, 2)

		var/list/demand = history["demand"]
		if(connected_powernet)
			demand += energy_to_power(connected_powernet.load)
		if(demand.len > record_size)
			demand.Cut(1, 2)

/obj/machinery/computer/monitor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerMonitor", name)
		ui.open()

/obj/machinery/computer/monitor/ui_data()
	var/datum/powernet/connected_powernet = get_powernet()
	var/list/data = list()
	data["stored"] = record_size
	data["interval"] = record_interval / 10
	data["attached"] = connected_powernet ? TRUE : FALSE
	data["history"] = history
	data["areas"] = list()

	if(connected_powernet)
		data["supply"] = display_power(connected_powernet.avail)
		data["demand"] = display_power(connected_powernet.load)
		for(var/obj/machinery/power/terminal/term in connected_powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A))
				var/cell_charge
				if(!A.cell)
					cell_charge = 0
				else
					cell_charge = A.cell.percent()
				data["areas"] += list(list(
					"name" = A.area.name,
					"charge" = cell_charge,
					"load" = display_power(A.lastused_total),
					"charging" = A.charging,
					"eqp" = A.equipment,
					"lgt" = A.lighting,
					"env" = A.environ
				))

	return data

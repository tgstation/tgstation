//normal computer version is located in code\modules\power\monitor.dm, /obj/machinery/computer/monitor

/datum/computer_file/program/power_monitor
	filename = "ampcheck"
	filedesc = "AmpCheck"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "power_monitor"
	extended_desc = "This program connects to sensors around the station to provide information about electrical systems"
	ui_header = "power_norm.gif"
	transfer_access = list(ACCESS_ENGINEERING)
	usage_flags = PROGRAM_CONSOLE
	requires_ntnet = FALSE
	size = 8
	tgui_id = "NtosPowerMonitor"
	program_icon = "plug"
	detomatix_resistance = DETOMATIX_RESIST_MINOR

	var/has_alert = 0
	var/datum/weakref/attached_wire_ref
	var/datum/weakref/local_apc_ref
	var/list/history = list()
	var/record_size = 60
	var/record_interval = 50
	var/next_record = 0


/datum/computer_file/program/power_monitor/on_start(mob/living/user)
	. = ..(user)
	search()
	history["supply"] = list()
	history["demand"] = list()


/datum/computer_file/program/power_monitor/process_tick(delta_time)
	if(!get_powernet())
		search()
	else
		record()

/datum/computer_file/program/power_monitor/proc/search() //keep in sync with /obj/machinery/computer/monitor's version
	var/turf/T = get_turf(computer)
	attached_wire_ref = WEAKREF(locate(/obj/structure/cable) in T)
	if(attached_wire_ref)
		return
	var/area/A = get_area(computer) //if the computer isn't directly connected to a wire, attempt to find the APC powering it to pull it's powernet instead
	if(!A)
		return
	var/obj/machinery/power/apc/local_apc = A.apc
	if(!local_apc)
		return
	if(!local_apc.terminal) //this really shouldn't happen without badminnery.
		local_apc = null
	local_apc_ref = WEAKREF(local_apc)

/datum/computer_file/program/power_monitor/proc/get_powernet() //keep in sync with /obj/machinery/computer/monitor's version
	var/obj/structure/cable/attached_wire = attached_wire_ref?.resolve()
	var/obj/machinery/power/apc/local_apc = local_apc_ref?.resolve()
	if(attached_wire || (local_apc?.terminal))
		return attached_wire ? attached_wire.powernet : local_apc.terminal.powernet
	return FALSE

/datum/computer_file/program/power_monitor/proc/record() //keep in sync with /obj/machinery/computer/monitor's version
	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/datum/powernet/connected_powernet = get_powernet()

		var/list/supply = history["supply"]
		if(connected_powernet)
			supply += connected_powernet.viewavail
		if(supply.len > record_size)
			supply.Cut(1, 2)

		var/list/demand = history["demand"]
		if(connected_powernet)
			demand += connected_powernet.viewload
		if(demand.len > record_size)
			demand.Cut(1, 2)

/datum/computer_file/program/power_monitor/ui_data()
	var/list/data = list()
	var/datum/powernet/connected_powernet = get_powernet()
	data["stored"] = record_size
	data["interval"] = record_interval / 10
	data["attached"] = connected_powernet ? TRUE : FALSE
	if(connected_powernet)
		data["supply"] = display_power(connected_powernet.viewavail)
		data["demand"] = display_power(connected_powernet.viewload)
	data["history"] = history

	data["areas"] = list()
	if(connected_powernet)
		for(var/obj/machinery/power/terminal/term in connected_powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A))
				data["areas"] += list(list(
					"name" = A.area.name,
					"charge" = A.cell ? A.cell.percent() : 0,
					"load" = display_power(A.lastused_total),
					"charging" = A.charging,
					"eqp" = A.equipment,
					"lgt" = A.lighting,
					"env" = A.environ
				))

	return data


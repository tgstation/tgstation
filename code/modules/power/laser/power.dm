
#define PTL_POWER_NONE 1
#define PTL_POWER_ENOUGH 2
#define PTL_POWER_INSUFFICIENT 3
#define PTL_POWER_OVERDRAW 4

/obj/machinery/power/PTL/connect_to_network()	//Intended to directly draw from linked storage in the future but for now it uses wires.
	if(terminal && terminal.powernet)
		return TRUE
	return FALSE

/obj/machinery/power/PTL/surplus()
	if(terminal)
		return terminal.surplus()
	return 0

/obj/machinery/power/PTL/avail()
	if(terminal)
		return terminal.avail()
	return 0

/obj/machinery/power/PTL/add_load(amount)
	if(terminal)
		return terminal.add_load(amount)
	return FALSE

/obj/machinery/power/PTL/add_avail(amount)
	if(terminal)
		return terminal.add_avail(amount)
	return FALSE

/obj/machinery/power/PTL/proc/check_powernet_for_amount(amount, overdraw_allowed = FALSE)
	if(!terminal.powernet)
		return PTL_POWER_NONE
	var/avail = surplus()
	if(avail >= amount)
		return PTL_POWER_ENOUGH
	else if(overdraw_allowed)
		return PTL_POWER_OVERDRAW
	else
		return PTL_POWER_INSUFFICIENT

/obj/machinery/power/PTL/proc/draw_from_powernet(amount, overdraw_allowed = FALSE)	//Returns amount taken from powernet. If overdrawing is allowed, powersink APCs for energy.
	if(!(terminal && terminal.powernet))
		return 0
	var/surplus = surplus()
	if(surplus >= amount)
		add_load(amount)
		return amount
	else if(!overdraw_allowed)
		add_load(surplus)
		return surplus
	else
		var/total_drawn = surplus
		add_load(surplus)
		overdraw_alert()
		for(var/obj/machinery/power/terminal/T in terminal.powernet.nodes)
			if(istype(T.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = T.master
				if(A.operating && A.cell)
					A.cell.charge = max(0, A.cell.charge - ptl_overdraw_apc_max)
					total_drawn += (ptl_overdraw_apc_max * ptl_overdraw_apc_multi)
					if(A.charging == 2)
						A.charging = 1
		return total_drawn

/obj/machinery/power/PTL/proc/overdraw_alert()
	var/area/A = get_area(src)
	priority_announce("Extreme overdraw detected at [A.name]. Powernet and attached machinery will be drained at a rapid rate.", title = "Powernet Overdraw Detected", sound = 'sound/misc/interference.ogg', "Priority")


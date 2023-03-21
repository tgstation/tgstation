/obj/machinery/recharge_station
	name = "recharging station"
	desc = "This device recharges energy dependent lifeforms, like cyborgs, ethereals and MODsuit users."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = FALSE
	req_access = list(ACCESS_ROBOTICS)
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/cyborgrecharger
	occupant_typecache = list(/mob/living/silicon/robot, /mob/living/carbon/human)
	processing_flags = NONE
	var/recharge_speed
	var/repairs


/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	update_appearance()
	if(is_operational)
		begin_processing()

	if(!mapload)
		return

	var/area/my_area = get_area(src)
	if(!(my_area.type in GLOB.the_station_areas))
		return

	var/area_name = get_area_name(src, format_text = TRUE)
	if(area_name in GLOB.roundstart_station_borgcharger_areas)
		return
	GLOB.roundstart_station_borgcharger_areas += area_name

/obj/machinery/recharge_station/RefreshParts()
	. = ..()
	recharge_speed = 0
	repairs = 0
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		recharge_speed += capacitor.tier * 100
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		repairs += manipulator.tier - 1
	for(var/obj/item/stock_parts/cell/cell in component_parts)
		recharge_speed *= cell.maxcharge / 10000

/obj/machinery/recharge_station/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharging <b>[recharge_speed]J</b> per cycle.")
		if(repairs)
			. += span_notice("[src] has been upgraded to support automatic repairs.")


/obj/machinery/recharge_station/on_set_is_operational(old_value)
	if(old_value) //Turned off
		end_processing()
	else //Turned on
		begin_processing()


/obj/machinery/recharge_station/process(delta_time)
	if(occupant)
		process_occupant(delta_time)
	return 1

/obj/machinery/recharge_station/relaymove(mob/living/user, direction)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	. = ..()
	if(!(machine_stat & (BROKEN|NOPOWER)))
		if(occupant && !(. & EMP_PROTECT_CONTENTS))
			occupant.emp_act(severity)
		if (!(. & EMP_PROTECT_SELF))
			open_machine()

/obj/machinery/recharge_station/attackby(obj/item/P, mob/user, params)
	if(state_open)
		if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", P))
			return

	if(default_pry_open(P))
		return

	if(default_deconstruction_crowbar(P))
		return
	return ..()

/obj/machinery/recharge_station/interact(mob/user)
	toggle_open()
	return TRUE

/obj/machinery/recharge_station/proc/toggle_open()
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	. = ..()
	update_use_power(IDLE_POWER_USE)

/obj/machinery/recharge_station/close_machine()
	. = ..()
	if(occupant)
		update_use_power(ACTIVE_POWER_USE) //It always tries to charge, even if it can't.
		add_fingerprint(occupant)

/obj/machinery/recharge_station/update_icon_state()
	if(!is_operational)
		icon_state = "borgcharger-u[state_open ? 0 : 1]"
		return ..()
	icon_state = "borgcharger[state_open ? 0 : (occupant ? 1 : 2)]"
	return ..()

/obj/machinery/recharge_station/proc/process_occupant(delta_time)
	if(!occupant)
		return
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, recharge_speed * delta_time / 2, repairs)

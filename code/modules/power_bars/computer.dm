/obj/machinery/computer/power_distribution
	name = "power level distribution console"
	desc = "Used to control the power level throughout the station. The more power a department has, the better their equipment will be."
	icon_screen = "ratvar2"
	icon_state = "ratvarcomputer3"
	icon_keyboard = "ratvar_key4"
	light_color = LIGHT_COLOR_YELLOW
	use_power = ACTIVE_POWER_USE
	circuit = /obj/item/circuitboard/computer/power_distribution
	tgui_id = "PowerLevelDistribution"
	req_access = list(ACCESS_ENGINEERING)

/obj/machinery/computer/power_distribution/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerLevelDistribution", name)
		ui.open()

/obj/machinery/computer/power_distribution/ui_data(mob/user)
	var/list/data = list()

	data["department_allocations"] = SSpower_bars.department_allocations
	data["available_power_bars"] = SSpower_bars.available_power_bars
	data["time_to_next_distribution"] = timeleft(SSpower_bars.next_distribution_timer_id)
	data["can_fully_deplete"] = can_deplete(user)

	return data

/obj/machinery/computer/power_distribution/ui_static_data(mob/user)
	var/list/data = list()

	data["max_power_bars"] = SSpower_bars.max_power_bars
	data["time_to_distribute"] = SSpower_bars.time_to_distribute

	return data

// MBTODO: Check access in ui_status (through get_id and friends)
/obj/machinery/computer/power_distribution/ui_act(action, list/params)
	var/mob/user = usr

	. = ..()
	if(.)
		return .

	switch (action)
		if ("set_department_power")
			var/department = params["department"]
			var/allocations = text2num(params["allocations"])

			if (!(department in SSpower_bars.department_allocations))
				return TRUE

			if (!can_deplete(user))
				allocations = max(allocations, 1)

			SSpower_bars.reassign_power_bar(department, allocations)
			user.log_message("updated power bar distribution, setting [department] to [allocations]. New distribution is [SSpower_bars.debug_power_bar_distributions()]", LOG_GAME)

	return TRUE

/obj/machinery/computer/power_distribution/proc/can_deplete(mob/user)
	// MBTODO: Chief engineers can deplete (really anyone with a specific access that can be given by ID console)
	return FALSE

/obj/item/circuitboard/computer/power_distribution
	name = "Power Level Distribution Console"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/power_distribution

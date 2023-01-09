GLOBAL_LIST_EMPTY_TYPED(power_distribution_consoles, /obj/machinery/computer/power_distribution)

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

	VAR_PRIVATE
		obj/item/radio/internal_radio

/obj/machinery/computer/power_distribution/Initialize(mapload)
	. = ..()

	GLOB.power_distribution_consoles += src

	internal_radio = new(src)
	internal_radio.keyslot = new /obj/item/encryptionkey/all_access
	internal_radio.recalculateChannels()

/obj/machinery/computer/power_distribution/Destroy()
	GLOB.power_distribution_consoles -= src

	QDEL_NULL(internal_radio)

	return ..()

/obj/machinery/computer/power_distribution/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerLevelDistribution", name)
		ui.open()

/obj/machinery/computer/power_distribution/ui_data(mob/user)
	var/list/data = list()

	var/list/available_power_bars = list()
	for (var/datum/power_bar_allocation/power_bar_allocation in SSpower_bars.available_power_bars)
		available_power_bars[power_bar_allocation.source] += power_bar_allocation.amount

	data["department_allocations"] = SSpower_bars.department_allocations
	data["available_power_bars"] = available_power_bars
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

/obj/machinery/computer/power_distribution/proc/speak(message, channel)
	PRIVATE_PROC(TRUE)
	internal_radio.talk_into(src, message, channel)
	return TRUE // MBTODO: return FALSE if wire is snipped

/obj/machinery/computer/power_distribution/proc/send_power_bar_update_message(list/current_allocations, list/last_allocations)
	var/any_passed = FALSE

	for (var/department in current_allocations)
		var/current_tier = current_allocations[department]
		var/last_tier = last_allocations[department]

		if (current_tier == last_tier)
			continue

		var/list/details = SSpower_bars.details_of_upgrade(department, current_tier, last_tier)

		var/message = "Your power allocation has been changed from [last_tier * 100]% to [current_tier * 100]%."
		if (details.len == 0 || last_tier > current_tier)
			message += " Your machines have been [current_tier > last_tier ? "upgraded" : "downgraded"]."
		else if (details.len > 0)
			message += " Along with machine upgrades, you have received other perks. " + details.Join(" ")

		for (var/channel in SSpower_bars.radio_channels_for_department(department))
			any_passed |= speak(message, channel)

	return any_passed

/obj/item/circuitboard/computer/power_distribution
	name = "Power Level Distribution Console"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/power_distribution

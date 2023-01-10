GLOBAL_LIST_EMPTY_TYPED(power_distribution_consoles, /obj/machinery/computer/power_distribution)

/obj/machinery/computer/power_distribution
	name = "power level distribution console"
	desc = "Used to control the power level throughout the station. The more power a department has, the better their equipment will be. APCs must be connected on the same powernet as this computer in order to receive the benefits."
	icon_screen = "ratvar2"
	icon_state = "ratvarcomputer3"
	icon_keyboard = "ratvar_key4"
	light_color = LIGHT_COLOR_YELLOW
	use_power = ACTIVE_POWER_USE
	circuit = /obj/item/circuitboard/computer/power_distribution
	tgui_id = "PowerLevelDistribution"

	req_access = list(ACCESS_ENGINEERING)

	VAR_PRIVATE
		last_checked_available_power_bars

		obj/item/radio/internal_radio

/obj/machinery/computer/power_distribution/Initialize(mapload)
	. = ..()

	GLOB.power_distribution_consoles += src

	internal_radio = new(src)
	internal_radio.keyslot = new /obj/item/encryptionkey/all_access
	internal_radio.recalculateChannels()

	RegisterSignal(SSpower_bars, COMSIG_POWER_BAR_AVAILABILITY_UPDATED, PROC_REF(on_power_bar_availability_updated))

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
	data["has_access"] = allowed(user)

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

			if (!isnull(last_checked_available_power_bars))
				last_checked_available_power_bars = null
				icon_screen = initial(icon_screen)
				update_appearance(UPDATE_OVERLAYS)

	return TRUE

/obj/machinery/computer/power_distribution/ui_status(mob/user)
	. = ..()

	if (!allowed(user))
		return min(., UI_UPDATE)

	return .

/obj/machinery/computer/power_distribution/emag_act(mob/user, obj/item/card/emag/emag_card)
	if (obj_flags & EMAGGED)
		return

	obj_flags |= EMAGGED
	balloon_alert(user, "overrode access")
	req_access.Cut()

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

/obj/machinery/computer/power_distribution/proc/send_power_bar_availability_changes(list/datum/power_bar_allocation/current_allocations, list/datum/power_bar_allocation/previous_allocations)
	var/list/current_sources = list()
	var/list/previous_sources = list()

	for (var/datum/power_bar_allocation/current_allocation in current_allocations)
		current_sources[current_allocation.source] += current_allocation.amount

	for (var/datum/power_bar_allocation/previous_allocation in previous_allocations)
		previous_sources[previous_allocation.source] += previous_allocation.amount

	var/list/message = list()

	for (var/source in (current_sources | previous_sources))
		var/current_amount = current_sources[source] || 0
		var/previous_amount = previous_sources[source] || 0

		if (current_amount == previous_amount)
			continue

		// This doesn't say "The", so it's in quotes
		message += "[abs(current_amount - previous_amount)] [current_amount > previous_amount ? "more" : "less"] power bar\s available from \"[source]\"."

	if (message.len == 0)
		return TRUE

	return speak(message.Join(" "), RADIO_CHANNEL_ENGINEERING)

/obj/machinery/computer/power_distribution/proc/on_power_bar_availability_updated(datum/source, current_count, previous_count)
	SIGNAL_HANDLER

	if (!isnull(last_checked_available_power_bars))
		if (current_count < last_checked_available_power_bars)
			last_checked_available_power_bars = null
			icon_screen = initial(icon_screen)
			update_appearance(UPDATE_OVERLAYS)

		return

	last_checked_available_power_bars = current_count
	icon_screen = "power_bar_alert"
	update_appearance(UPDATE_OVERLAYS)

/obj/item/circuitboard/computer/power_distribution
	name = "Power Level Distribution Console"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/computer/power_distribution

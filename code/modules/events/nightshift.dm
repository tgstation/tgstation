/datum/round_event_control/nightshift
	name = "Night Shift"
	typepath = /datum/round_event/nightshift
	weight = 2
	max_occurrences = 1
	earliest_start = 30 SECONDS
	category = EVENT_CATEGORY_FRIENDLY
	description = "Sets the station's lights to Night Shift mode for the next 20 minutes."

/datum/round_event_control/nightshift/New()
	. = ..()
	if(!CONFIG_GET(flag/enable_night_shifts))
		max_occurrences = 0

/datum/round_event/nightshift
	announce_when = 1
	start_when = 1
	end_when = 700 //~22 Minutes
	fakeable = FALSE

	/// Tracks if the station is currently in an emergency (disabling the effects of the event)
	VAR_PRIVATE/emergency = FALSE
	/// If we ever actually got the initial message
	VAR_PRIVATE/ever_started = FALSE
	/// APCs to update through ticks to account for lag.
	VAR_PRIVATE/list/currentrun
	/// What state we want the APCs in currentrun to set to; null for no target state
	VAR_PRIVATE/desired_apc_state = null

/datum/round_event/nightshift/announce(fake)
	var/emergency = (SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
	if(!emergency)
		update_nightshift(active = TRUE, announce = TRUE)
		ever_started = TRUE

	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_security_level_changed))

/datum/round_event/nightshift/proc/on_security_level_changed(datum/source, new_level)
	SIGNAL_HANDLER

	if(emergency)
		if(new_level >= SEC_LEVEL_RED)
			return
	else
		if(new_level < SEC_LEVEL_RED)
			return

	emergency = !emergency
	update_nightshift(active = !emergency, resume = ever_started)

/datum/round_event/nightshift/end()
	if(ever_started)
		update_nightshift(active = FALSE, announce = !emergency)
	UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	currentrun = null

///Called several times, to start & stop nightlights including during red alert/de-red alerting.
/datum/round_event/nightshift/proc/update_nightshift(active = FALSE, resume = FALSE, announce = FALSE)
	if(announce)
		if(active)
			send_announcement("Good evening, crew. To reduce power consumption and stimulate the circadian rhythms of some species, all of the lights aboard the station have been dimmed for the night.")
		else
			send_announcement("Good morning, crew. As it is now day time, all of the lights aboard the station have been restored to their former brightness.")

	if(resume)
		if(active)
			send_announcement("Restoring night lighting configuration to normal operation.")
		else
			send_announcement("Disabling night lighting: Station is in a state of emergency.")

	currentrun = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)
	desired_apc_state = active

/datum/round_event/nightshift/tick()
	if(!length(currentrun))
		desired_apc_state = null
		return

	for(var/obj/machinery/power/apc/APC as anything in currentrun)
		currentrun -= APC
		if (APC.area && (APC.area.type in GLOB.the_station_areas))
			APC.set_nightshift(desired_apc_state)
		if(TICK_CHECK)
			return

///Custom messages sent throughout the event that we'll do here, instead of using the `announce` proc that's only at the start.
/datum/round_event/nightshift/proc/send_announcement(message)
	priority_announce(
		text = message,
		sound = 'sound/announcer/notice/notice2.ogg',
		sender_override = "Automated Lighting System Announcement",
		color_override = "grey",
	)

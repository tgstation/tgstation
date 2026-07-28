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

	///Whether the nightshift is on or not, synced to the alert level (which decides whether we're active)
	///TRUE means they are disabled by red alert.
	var/nightshift_disabled = FALSE
	///APCs to update through ticks to account for lag.
	var/list/currentrun

/datum/round_event/nightshift/announce(fake)
	update_nightshift(active = TRUE, announce = TRUE)

/datum/round_event/nightshift/tick()
	var/emergency = (SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
	if(nightshift_disabled != emergency)
		nightshift_disabled = emergency
		if(emergency)
			update_nightshift(active = FALSE, resume = TRUE)
		else
			update_nightshift(active = TRUE, resume = TRUE)

	update_machines()

/datum/round_event/nightshift/end()
	update_nightshift(active = FALSE, announce = TRUE)

///Called several times, to start & stop nightlights including during red alert/de-red alerting.
/datum/round_event/nightshift/proc/update_nightshift(active, resume = FALSE, announce = FALSE)
	currentrun = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc)

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

	update_machines()

///Called on process that will slowly update all APCs to be nightlight
/datum/round_event/nightshift/proc/update_machines()
	for(var/obj/machinery/power/apc/APC as anything in currentrun)
		currentrun -= APC
		if (APC.area && (APC.area.type in GLOB.the_station_areas))
			APC.set_nightshift(!nightshift_disabled)
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

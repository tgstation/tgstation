/obj/machinery/spaceship_navigation_beacon
	name = "radio navigation gigabeacon"
	desc = "A device that constantly transmits its position over several different commonly used maritime navigation frequencies. Used to create shuttle navigation waypoints in unexplored or undeveloped areas."
	icon = 'icons/obj/machines/navigation_beacon.dmi'
	icon_state = "beacon_active"
	base_icon_state = "beacon"
	density = TRUE
	flags_1 = NODECONSTRUCT_1

	/// Locked beacons cannot be jumped to by ships.
	var/locked = FALSE
	/// Time between automated messages.
	var/automatic_message_cooldown = 5 MINUTES
	/// Next world tick to send an automatic message.
	var/next_automatic_message_time
	/// Our internal radio.
	var/obj/item/radio/radio

/obj/machinery/spaceship_navigation_beacon/Initialize(mapload)
	. = ..()
	SSshuttle.beacon_list |= src

	name = "[initial(src.name)] [z]-[rand(0, 999)]"

	var/static/list/multitool_tips = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Edit beacon name",
			SCREENTIP_CONTEXT_RMB = "Lock/Unlock beacon",
		)
	)
	AddElement(/datum/element/contextual_screentip_tools, multitool_tips)

	radio = new(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_RADIO_NAV_BEACON)
	radio.freqlock = RADIO_FREQENCY_LOCKED
	radio.recalculateChannels()

	START_PROCESSING(SSmachines, src)
	COOLDOWN_START(src, next_automatic_message_time, automatic_message_cooldown)

/obj/machinery/spaceship_navigation_beacon/emp_act()
	locked = TRUE
	update_icon_state()

/obj/machinery/spaceship_navigation_beacon/Destroy()
	SSshuttle.beacon_list -= src
	return ..()

/obj/machinery/spaceship_navigation_beacon/update_icon_state()
	icon_state = "[base_icon_state][locked ? "_locked" : "_active"]"
	return ..()

/obj/machinery/spaceship_navigation_beacon/multitool_act(mob/living/user, obj/item/tool)
	..()

	var/chosen_tag = tgui_input_text(user, "Enter the custom name for this beacon", "Beacon Reclassification", max_length = MAX_NAME_LEN)
	if(!chosen_tag)
		return

	var/new_name = "[initial(src.name)] [chosen_tag]"
	if(new_name && Adjacent(user))
		name = new_name
		balloon_alert_to_viewers("beacon renamed")

	return TRUE

/obj/machinery/spaceship_navigation_beacon/multitool_act_secondary(mob/living/user, obj/item/tool)
	..()

	locked = !locked

	balloon_alert_to_viewers("[!locked ? "unlocked" : "locked"]")
	update_icon_state()

	return TRUE

/obj/machinery/spaceship_navigation_beacon/examine()
	.=..()
	. += span_notice("'[FREQ_RADIO_NAV_BEACON / 10] kHz' is printed on the side.")
	if(locked)
		. += span_warning("The blinking red light on the front indicates that this beacon is LOCKED.")
	else
		. += span_notice("The blinking green light on the front indicates that this beacon is operating normally.")

/obj/machinery/spaceship_navigation_beacon/process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, next_automatic_message_time) && radio)
		var/automatic_nav_message = "[src], Sector [z], [locked ? "Beacon Locked" : "Beacon Operational"], Grid Coordinates, [x] East, [y] North."

		radio.talk_into(src, "[automatic_nav_message]")

		COOLDOWN_START(src, next_automatic_message_time, automatic_message_cooldown)

// Item used to actually make nav beacons

/obj/item/folded_navigation_gigabeacon
	name = "compact radio navigation gigabeacon"
	desc = "A compact radio navigation gigabeacon, a device used to provide shuttle navigation waypoints in unexplored areas. Must be deployed before use."
	icon = 'icons/obj/machines/navigation_beacon.dmi'
	icon_state = "beacon_folded"

/obj/item/folded_navigation_gigabeacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 3 SECONDS, /obj/machinery/spaceship_navigation_beacon, delete_on_use = TRUE)

/obj/item/folded_navigation_gigabeacon/examine()
	.=..()
	. += span_notice("The backside has instructions in various galactic languages detailing how this can be deployed <b>in hand</b> without any special tools.")
	. += span_notice("'[FREQ_RADIO_NAV_BEACON / 10] kHz' is printed on the side.")

/obj/item/assembly/control/icts
	///the transport ID we're making requests about
	var/specific_transport_id = TRAMSTATION_LINE_1
	///options to be passed with the requests
	var/options = NONE

/obj/item/assembly/control/icts/multitool_act(mob/living/user)
	var/list/available_platforms = list()
	for(var/obj/effect/landmark/icts/nav_beacon/tram/platform/platform as anything in SStransport.nav_beacons[specific_transport_id])
		LAZYADD(available_platforms, platform.name)

	var/selected_platform = tgui_input_list(user, "Set the platform ID", "Platform", available_platforms)
	var/obj/effect/landmark/icts/nav_beacon/tram/platform/change_platform
	for(var/obj/effect/landmark/icts/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
		if(destination.name == selected_platform)
			change_platform = destination
			break

	if(!change_platform || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	if(get_dist(change_platform, src) > 15)
		balloon_alert(user, "out of range!")
		return

	id = change_platform.platform_code
	balloon_alert(user, "platform changed")
	to_chat(user, span_notice("You change the platform ID to [change_platform.name]."))

/obj/item/assembly/control/icts/call_button
	name = "tram call button"
	desc = "A small device used to bring trams to you."
	///ID to link to allow us to link to one specific tram in the world
	id = 0

/obj/item/assembly/control/icts/call_button/Initialize(mapload)
	..()
	SStransport.hello(src)
	RegisterSignal(SStransport, COMSIG_ICTS_RESPONSE, PROC_REF(call_response))

/obj/item/assembly/control/icts/proc/call_response(controller, list/relevant, response_code, response_info)
	SIGNAL_HANDLER
	if(!LAZYFIND(relevant, src))
		return

	switch(response_code)
		if(REQUEST_SUCCESS)
			say("The tram has been called to the platform.")

		if(REQUEST_FAIL)
			switch(response_info)
				if(NOT_IN_SERVICE) //tram is QDEL or has no power
					say("The tram is not in service. Please contact the nearest engineer.")
				if(INVALID_PLATFORM) //engineer needs to fix button
					say("Button configuration error. Please contact the nearest engineer.")
				if(TRANSPORT_IN_USE)
					say("The tram is tramversing the station, please wait.")
				if(PLATFORM_DISABLED)
					say("The tram is set to skip this platform.")
				if(NO_CALL_REQUIRED) //already here
					say("The tram is already here. Please board the tram and select a destination.")
				else
					say("Tram controller error. Please contact the nearest engineer.")

/obj/item/assembly/control/icts/call_button/activate()
	if(cooldown)
		return
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)

	// INVOKE_ASYNC(SStransport, TYPE_PROC_REF(/datum/controller/subsystem/processing/transport, call_request), src, specific_transport_id, id)
	SEND_SIGNAL(src, COMSIG_ICTS_REQUEST, specific_transport_id, id)

/obj/machinery/button/icts/tram
	name = "tram request"
	desc = "A button for calling the tram. It has a speakerbox in it with some internals."
	base_icon_state = "tram"
	icon_state = "tram"
	light_color = LIGHT_COLOR_DARK_BLUE
	can_alter_skin = FALSE
	device_type = /obj/item/assembly/control/icts/call_button
	req_access = list()
	var/specific_transport_id = TRAMSTATION_LINE_1
	id = 0

/obj/machinery/button/icts/tram/setup_device()
	var/obj/item/assembly/control/icts/call_button/icts_device = device
	icts_device.id = id
	icts_device.specific_transport_id = specific_transport_id
	return ..()

/obj/machinery/button/icts/tram/examine(mob/user)
	. = ..()
	. += span_notice("There's a small inscription on the button...")
	. += span_notice("THIS CALLS THE TRAM! IT DOES NOT OPERATE IT! The console on the tram tells it where to go!")

/obj/item/assembly/control/icts/call_button/proc/debug_autotram(platform)
	var/next_platform
	if(platform)
		next_platform = platform + 1
	else
		next_platform = 1

	if(next_platform > 3)
		next_platform = 1

	SEND_SIGNAL(src, COMSIG_ICTS_REQUEST, specific_transport_id, next_platform)
	addtimer(CALLBACK(src, PROC_REF(debug_autotram), next_platform), 10 SECONDS)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/icts/tram, 32)

/obj/machinery/button/icts/tram/estop
	name = "tram request"
	desc = "A button for calling the tram. It has a speakerbox in it with some internals."
	base_icon_state = "tram"
	icon_state = "tram"
	light_color = LIGHT_COLOR_DARK_BLUE
	can_alter_skin = FALSE
	device_type = /obj/item/assembly/control/icts/call_button
	req_access = list()
	specific_transport_id = TRAMSTATION_LINE_1
	id = 0

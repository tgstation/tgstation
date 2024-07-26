/obj/item/assembly/control/transport
	/// The ID of the tram we're linked to
	var/specific_transport_id = TRAMSTATION_LINE_1
	/// Options to be passed with the requests to the transport subsystem
	var/options = NONE

/obj/item/assembly/control/transport/multitool_act(mob/living/user)
	var/list/available_platforms = list()
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/platform as anything in SStransport.nav_beacons[specific_transport_id])
		LAZYADD(available_platforms, platform.name)

	var/selected_platform = tgui_input_list(user, "Set the platform ID", "Platform", available_platforms)
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/change_platform
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[specific_transport_id])
		if(destination.name == selected_platform)
			change_platform = destination
			break

	if(!change_platform || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return

	if(get_dist(change_platform, src) > 15)
		balloon_alert(user, "out of range!")
		return

	id = change_platform.platform_code
	balloon_alert(user, "platform changed")
	to_chat(user, span_notice("You change the platform ID to [change_platform.name]."))

/obj/item/assembly/control/transport/call_button
	name = "tram call button"
	desc = "A small device used to bring trams to you."
	///ID to link to allow us to link to one specific tram in the world
	id = 0

/obj/item/assembly/control/transport/call_button/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/assembly/control/transport/call_button/LateInitialize()
	if(!id_tag)
		id_tag = assign_random_name()
	SStransport.hello(src, name, id_tag)
	RegisterSignal(SStransport, COMSIG_TRANSPORT_RESPONSE, PROC_REF(call_response))

/obj/item/assembly/control/transport/proc/call_response(controller, list/relevant, response_code, response_info)
	SIGNAL_HANDLER
	if(!LAZYFIND(relevant, src))
		return

	switch(response_code)
		if(REQUEST_SUCCESS)
			say("The tram has been called to the platform.")

		if(REQUEST_FAIL)
			switch(response_info)
				if(BROKEN_BEYOND_REPAIR)
					say("The tram has suffered a catastrophic failure. Please seek alternate modes of travel.")
				if(NOT_IN_SERVICE) //tram has no power or other fault, but it's not broken forever
					say("The tram is not in service due to loss of power or system problems. Please contact the nearest engineer to check power and controller.")
				if(INVALID_PLATFORM) //engineer needs to fix button
					say("Button configuration error. Please contact the nearest engineer.")
				if(TRANSPORT_IN_USE)
					say("The tram is tramversing the station, please wait.")
				if(INTERNAL_ERROR)
					say("Tram controller error. Please contact the nearest engineer or crew member with telecommunications access to reset the controller.")
				if(NO_CALL_REQUIRED) //already here
					say("The tram is already here. Please board the tram and select a destination.")
				else
					say("Tram controller error. Please contact the nearest engineer or crew member with telecommunications access to reset the controller.")

/obj/item/assembly/control/transport/call_button/activate()
	if(cooldown)
		return
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)

	// INVOKE_ASYNC(SStransport, TYPE_PROC_REF(/datum/controller/subsystem/processing/transport, call_request), src, specific_transport_id, id)
	SEND_SIGNAL(src, COMSIG_TRANSPORT_REQUEST, specific_transport_id, id)

/obj/machinery/button/transport/tram
	name = "tram request"
	desc = "A button for calling the tram. It has a speakerbox in it with some internals."
	base_icon_state = "tram"
	icon_state = "tram"
	light_color = COLOR_DISPLAY_BLUE
	can_alter_skin = FALSE
	device_type = /obj/item/assembly/control/transport/call_button
	req_access = list()
	id = 0
	/// The ID of the tram we're linked to
	var/specific_transport_id = TRAMSTATION_LINE_1

/// We allow borgs to use the button locally, but not the AI remotely
/obj/machinery/button/transport/tram/attack_ai(mob/user)
	if(isAI(user) || panel_open)
		return
	if(HAS_SILICON_ACCESS(user) && !issilicon(user)) //admins and remote controls can use it at a distance
		return attack_hand(user)
	if(in_range(user, src))
		return attack_hand(user)
	else
		to_chat(user, span_warning("You are too far away to activate the button!"))

/obj/machinery/button/transport/tram/setup_device()
	var/obj/item/assembly/control/transport/call_button/tram_device = device
	tram_device.id = id
	tram_device.specific_transport_id = specific_transport_id
	return ..()

/obj/machinery/button/transport/tram/examine(mob/user)
	. = ..()
	. += span_notice("There's a small inscription on the button...")
	. += span_notice("THIS CALLS THE TRAM! IT DOES NOT OPERATE IT! The console on the tram tells it where to go!")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/transport/tram, 32)

#define TRAMCTRL_INBOUND 1
#define TRAMCTRL_OUTBOUND 0
#define TRAMCTRL_FAST 1
#define TRAMCTRL_SAFE 0

/obj/item/assembly/control/icts/remote
	icon_state = "tramremote_nis"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "tram remote"
	desc = "A remote control that can be linked to a tram. This can only go well."
	w_class = WEIGHT_CLASS_TINY
	///desired tram destination
	var/destination
	///current tram direction
	var/direction
	///fast and fun, or safe and boring
	options = RAPID_MODE

/obj/item/assembly/control/icts/remote/Initialize(mapload)
	. = ..()
	SSicts_transport.hello(src)
	RegisterSignal(SSicts_transport, COMSIG_ICTS_RESPONSE, PROC_REF(call_response))
	register_context()

/obj/item/assembly/control/icts/remote/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!specific_transport_id)
		context[SCREENTIP_CONTEXT_LMB] = "Link tram"
		return CONTEXTUAL_SCREENTIP_SET
	context[SCREENTIP_CONTEXT_LMB] = "Dispatch tram"
	context[SCREENTIP_CONTEXT_RMB] = "Select destination"
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Toggle door safeties"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Change tram"
	return CONTEXTUAL_SCREENTIP_SET

///set tram control direction
/obj/item/assembly/control/icts/remote/attack_self_secondary(mob/user)
	//var/datum/transport_controller/linear/tram/tram_controller = tram_ref?.resolve()
	if(!specific_transport_id)
		balloon_alert(user, "no tram linked!")
		return

	destination = null
	var/list/potential_destinations = get_destinations()
	var/list/requested_destination = list()
	requested_destination = tgui_input_list(user, "Available destinations", "Where to?", potential_destinations)
	destination = requested_destination["platform_code"]
	update_appearance()
	// balloon_alert(user, "[direction ? "< inbound" : "outbound >"]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/assembly/control/icts/proc/get_destinations()
	. = list()
	for(var/obj/effect/landmark/icts/nav_beacon/tram/destination as anything in SSicts_transport.nav_beacons[specific_transport_id])
		var/list/this_destination = list()
		this_destination["name"] = destination.name
		this_destination["dest_icons"] = destination.tgui_icons
		this_destination["id"] = destination.platform_code
		. += list(this_destination)

///set safety bypass
/obj/item/assembly/control/icts/remote/CtrlClick(mob/user)
	switch(options)
		if(!RAPID_MODE)
			options |= RAPID_MODE
		if(RAPID_MODE)
			options &= ~RAPID_MODE
	update_appearance()
	balloon_alert(user, "mode: [options ? "fast" : "safe"]")

/obj/item/assembly/control/icts/remote/examine(mob/user)
	. = ..()
	if(!specific_transport_id)
		. += "There is an X showing on the display."
		. += "Left-click to link to a tram."
		return
	. += "The arrow on the display is pointing [direction ? "inbound" : "outbound"]."
	. += "The rapid mode light is [options ? "on" : "off"]."
	if(cooldown)
		. += "The number on the display shows [DisplayTimeText(cooldown, 1)]."
	else
		. += "The display indicates ready."
	. += "Left-click to dispatch tram."
	. += "Right-click to set destination."
	. += "Ctrl-click to toggle safety bypass."

/obj/item/assembly/control/icts/remote/update_icon_state()
	. = ..()

	if(!specific_transport_id)
		icon_state = "tramremote_nis"
		return
	switch(direction)
		if(TRAMCTRL_INBOUND)
			icon_state = "tramremote_ib"
		if(TRAMCTRL_OUTBOUND)
			icon_state = "tramremote_ob"

/obj/item/assembly/control/icts/remote/update_overlays()
	. = ..()
	if(options & RAPID_MODE)
		. += mutable_appearance(icon, "tramremote_emag")

/obj/item/assembly/control/icts/remote/attack_self(mob/user)
	if(!specific_transport_id)
		link_tram(user)
		return

	if(cooldown)
		balloon_alert(user, "cooldown: [DisplayTimeText(cooldown, 1)]")
		return

	activate(user)
	//	COOLDOWN_START(src, tram_remote, 2 MINUTES)

///send our selected commands to the tram
/obj/item/assembly/control/icts/remote/activate(mob/user)
	if(!specific_transport_id)
		balloon_alert(user, "no tram linked!")
		return
	if(!destination)
		balloon_alert(user, "no destination!")
		return

	SEND_SIGNAL(src, COMSIG_ICTS_REQUEST, specific_transport_id, destination, options)

/obj/item/assembly/control/icts/remote/AltClick(mob/user)
	link_tram(user)

/obj/item/assembly/control/icts/remote/proc/link_tram(mob/user)
	specific_transport_id = null
	var/list/transports_available
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		LAZYADD(transports_available, tram.specific_transport_id)

	specific_transport_id = tgui_input_list(user, "Available transports", "Select a transport", transports_available)

	if(specific_transport_id)
		balloon_alert(user, "tram linked")
	else
		balloon_alert(user, "link failed!")

	update_appearance()

#undef TRAMCTRL_INBOUND
#undef TRAMCTRL_OUTBOUND
#undef TRAMCTRL_FAST
#undef TRAMCTRL_SAFE

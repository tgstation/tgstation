/obj/item/mcobject/messaging/relay
	name = "relay component"
	base_icon_state = "comp_relay"
	icon_state = "comp_relay"

	var/replace_message = FALSE

/obj/item/mcobject/messaging/relay/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("input 1", relay)
	MC_ADD_INPUT("input 2", relay)
	MC_ADD_INPUT("input 3", relay)
	MC_ADD_INPUT("input 4", relay)
	MC_ADD_INPUT("input 5", relay)
	MC_ADD_INPUT("input 6", relay)
	MC_ADD_INPUT("input 7", relay)
	MC_ADD_INPUT("input 8", relay)
	MC_ADD_INPUT("input 9", relay)
	MC_ADD_INPUT("input 10", relay)
	MC_ADD_CONFIG("Toggle Message Replacement", toggle_replace)

/obj/item/mcobject/messaging/relay/examine(mob/user)
	. = ..()
	. += span_notice("Message Replacement is [replace_message ? "on" : "off"].")

/obj/item/mcobject/messaging/relay/proc/relay(datum/mcmessage/input)
	flick("[anchored ? "u":""]comp_relay1", src)
	if(replace_message)
		fire(stored_message, input)
	else
		fire(input)

/obj/item/mcobject/messaging/relay/proc/toggle_replace(mob/user, obj/item/tool)
	replace_message = !replace_message
	to_chat(user, span_notice("You set [src] to [replace_message ? "replace the incoming message" : "relay the incoming message"]."))
	log_message("replacement set to [replace_message] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

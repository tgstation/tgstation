///The messaging type. Use this to pass text data around between components.
/obj/item/mcobject/messaging
	///The message we're prepared to send
	var/stored_message = MC_BOOL_TRUE

	///The message trigger field. Use MC_ADD_TRIGGER to utilize.
	var/trigger = MC_BOOL_TRUE

/obj/item/mcobject/messaging/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG(MC_CFG_OUTPUT_MESSAGE, set_output)

/obj/item/mcobject/messaging/examine(mob/user)
	. = ..()
	if(configs[MC_CFG_OUTPUT_MESSAGE])
		. += span_notice("Output message: [stored_message]")

/obj/item/mcobject/messaging/proc/set_output(mob/user, obj/item/tool)
	var/msg = input(user, "Enter new message:", "Configure Component", stored_message)

	if(isnull(msg))
		return

	stored_message = msg
	to_chat(user, span_notice("You set [src]'s output message to [html_encode(stored_message)]"))
	log_message("output message set to [stored_message] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/proc/set_trigger(mob/user, obj/item/tool)
	var/msg = input(user, "Enter trigger field:", "Configure Component", trigger)

	if(isnull(msg))
		return
	trigger = msg
	to_chat(user, span_notice("You set the trigger of [src] to [html_encode(trigger)]."))
	log_message("trigger message set to [trigger] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

///Relay a message to our outputs.
/obj/item/mcobject/messaging/proc/fire(text, datum/mcmessage/relay)
	SHOULD_CALL_PARENT(TRUE)
	. = interface.Send(text, relay)
	if(.)
		flash()

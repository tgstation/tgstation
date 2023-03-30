
/obj/item/mcobject/messaging/signal_builder
	name = "message builder component"
	base_icon_state = "comp_builder"
	icon_state = "comp_builder"

	var/buffer = ""
	var/start_str = ""
	var/end_str = ""

/obj/item/mcobject/messaging/signal_builder/Initialize(mapload)
	. = ..()
	configs -= MC_CFG_OUTPUT_MESSAGE
	MC_ADD_INPUT("append to buffer", append_to_buffer)
	MC_ADD_INPUT("append to buffer + send", append_to_buffer_and_send)
	MC_ADD_INPUT("send", send)
	MC_ADD_INPUT("clear buffer", clear_buffer)
	MC_ADD_INPUT("set leading string", set_prefix)
	MC_ADD_INPUT("set trailing string", set_suffix)
	MC_ADD_CONFIG("Set Leading String", set_prefix_config)
	MC_ADD_CONFIG("Set Trailing String", set_suffix_config)

/obj/item/mcobject/messaging/signal_builder/examine(mob/user)
	. = ..()
	. += span_notice("Current buffer contents: [sanitize(buffer)]")
	. += span_notice("Current leading string: [sanitize(start_str)]")
	. += span_notice("Current trailing string: [sanitize(end_str)]")

/obj/item/mcobject/messaging/signal_builder/proc/set_prefix(datum/mcmessage/input)
	start_str = input.cmd

/obj/item/mcobject/messaging/signal_builder/proc/set_suffix(datum/mcmessage/input)
	end_str = input.cmd

/obj/item/mcobject/messaging/signal_builder/proc/set_prefix_config(mob/user, obj/item/tool)
	var/msg = input(user, "Input a leading string", "Configure Component", start_str)
	start_str = msg
	to_chat(user, span_notice("You set the leading string of [src] to [html_encode(start_str)]."))
	return TRUE

/obj/item/mcobject/messaging/signal_builder/proc/set_suffix_config(mob/user, obj/item/tool)
	var/msg = input(user, "Input a trailing string", "Configure Component", end_str)
	end_str = msg
	to_chat(user, span_notice("You set the trailing string of [src] to [html_encode(start_str)]."))
	return TRUE

/obj/item/mcobject/messaging/signal_builder/proc/append_to_buffer(datum/mcmessage/input)
	buffer = "[buffer][input.cmd]"

/obj/item/mcobject/messaging/signal_builder/proc/send(datum/mcmessage/input)
	var/message = "[start_str][buffer][end_str]"
	input.cmd = message
	fire(input)
	buffer = ""

/obj/item/mcobject/messaging/signal_builder/proc/append_to_buffer_and_send(datum/mcmessage/input)
	append_to_buffer(input)
	send(input)

/obj/item/mcobject/messaging/signal_builder/proc/clear_buffer(datum/mcmessage/input)
	buffer = ""

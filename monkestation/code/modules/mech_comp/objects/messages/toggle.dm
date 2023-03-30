/obj/item/mcobject/messaging/toggle
	name = "toggle component"
	base_icon_state = "comp_toggle"
	icon_state = "comp_toggle"

	var/on = FALSE
	var/on_signal = MC_BOOL_TRUE
	var/off_signal = MC_BOOL_FALSE

/obj/item/mcobject/messaging/toggle/examine(mob/user)
	. = ..()
	. += span_notice("Currently [on ? "ON":"OFF"]")
	. += span_notice("Current ON Message: [on_signal]")
	. += span_notice("Current OFF Message: [off_signal]")

/obj/item/mcobject/messaging/toggle/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("activate", activate)
	MC_ADD_INPUT("activate and send", activate_and_send)
	MC_ADD_INPUT("deactivate", deactivate)
	MC_ADD_INPUT("deactivate and send", deactivate_and_send)
	MC_ADD_INPUT("toggle", toggle)
	MC_ADD_INPUT("toggle and send", toggle_and_send)
	MC_ADD_INPUT("send", send)
	MC_ADD_CONFIG("Set On Message", set_on_message)
	MC_ADD_CONFIG("Set Off Message", set_off_message)

/obj/item/mcobject/messaging/toggle/proc/send(datum/mcmessage/input)
	input.cmd = (on ? on_signal : off_signal)
	fire(input)

/obj/item/mcobject/messaging/toggle/proc/activate(datum/mcmessage/input)
	on = TRUE

/obj/item/mcobject/messaging/toggle/proc/activate_and_send(datum/mcmessage/input)
	activate(input)
	send(input)

/obj/item/mcobject/messaging/toggle/proc/deactivate(datum/mcmessage/input)
	on = FALSE

/obj/item/mcobject/messaging/toggle/proc/deactivate_and_send(datum/mcmessage/input)
	deactivate(input)
	send(input)

/obj/item/mcobject/messaging/toggle/proc/toggle(datum/mcmessage/input)
	on = !on

/obj/item/mcobject/messaging/toggle/proc/toggle_and_send(datum/mcmessage/input)
	toggle(input)
	send(input)

/obj/item/mcobject/messaging/toggle/proc/set_on_message(mob/user, obj/item/tool)
	var/msg = input(user, "Input a string:", "Configure Component", on_signal)
	if(!msg)
		return
	on_signal = msg
	to_chat(user, span_notice("You set [src]'s ON message to [html_encode(on_signal)]."))
	return TRUE

/obj/item/mcobject/messaging/toggle/proc/set_off_message(mob/user, obj/item/tool)
	var/msg = input(user, "Input a string:", "Configure Component", off_signal)
	if(!msg)
		return
	off_signal = msg
	to_chat(user, span_notice("You set [src]'s OFF message to [html_encode(off_signal)]."))
	return TRUE

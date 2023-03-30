/obj/item/mcobject/messaging/signal_check
	name = "simple find component"
	base_icon_state = "comp_check"
	icon_state = "comp_check"

	var/replace_message = FALSE
	var/fire_on_found = TRUE
	var/exact = FALSE

/obj/item/mcobject/messaging/signal_check/Initialize(mapload)
	. = ..()
	MC_ADD_TRIGGER
	MC_ADD_INPUT("set trigger", set_trigger_comp)
	MC_ADD_INPUT("check string", check_str)
	MC_ADD_CONFIG("Invert Trigger", invert_trigger)
	MC_ADD_CONFIG("Toggle Message Replacement", toggle_replace)
	MC_ADD_CONFIG("Toggle Exact Search", toggle_exact)

/obj/item/mcobject/messaging/signal_check/examine(mob/user)
	. = ..()
	. += span_notice("[!fire_on_found ? "Component triggers when Signal is NOT found.":"Component triggers when Signal IS found."]")
	. += span_notice("Message Replacement is [replace_message ? "on.":"off."]")
	. += span_notice("Currently checking for: [strip_html(trigger)]")
	. += span_notice("Exact Search is [exact ? "on" : "off"].")

/obj/item/mcobject/messaging/signal_check/proc/set_trigger_comp(datum/mcmessage/input)
	trigger = input.cmd

/obj/item/mcobject/messaging/signal_check/proc/invert_trigger(mob/user, obj/item/tool)
	fire_on_found = !fire_on_found
	to_chat(user, span_notice("You set [src] to trigger [fire_on_found ? "when the check is found" : "when the check is NOT found"]."))
	return TRUE

/obj/item/mcobject/messaging/signal_check/proc/toggle_replace(mob/user, obj/item/tool)
	replace_message = !replace_message
	to_chat(user, span_notice("You set [src] to [replace_message ? "forward it's own message":"forward the inputted message"]."))
	return TRUE

/obj/item/mcobject/messaging/signal_check/proc/toggle_exact(mob/user, obj/item/tool)
	exact = !exact
	to_chat(user, span_notice("You set [src] to [exact ? "only look for exact matches":"look for any occurances"]."))
	return TRUE

/obj/item/mcobject/messaging/signal_check/proc/check_str(datum/mcmessage/input)
	var/found = exact ? (input.cmd == trigger) : findtext(input.cmd, trigger)
	if(found)
		if(fire_on_found)
			if(replace_message)
				fire(stored_message, input)
			else
				fire(input)

	else
		if(!fire_on_found)
			if(replace_message)
				fire(stored_message, input)
			else
				fire(input)

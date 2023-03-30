//The code here exists because MARKNSTEIN let kapu port it to the GPL version of mech comp, thank you Marknstein


/obj/item/mcobject/messaging/dispatch
	name = "dispatch component"
	base_icon_state = "comp_disp"
	icon_state = "comp_disp"

	var/exact_match = FALSE
	var/single_output = FALSE

	//This stores all the relevant filters per output
	//Notably, this list doesn't remove entries when an output is removed.
	//So it will bloat over time...
	var/list/outgoing_filters

/obj/item/mcobject/messaging/dispatch/Initialize(mapload)
	. = ..()
	outgoing_filters = list()
	RegisterSignal(interface, MCACT_PRE_SEND_MESSAGE, PROC_REF(run_filter))
	RegisterSignal(interface, MCACT_REMOVE_INPUT, PROC_REF(remove_message_filter))

	MC_ADD_INPUT("dispatch", dispatch)
	MC_ADD_CONFIG("Toggle Exact Matching", toggle_match)
	MC_ADD_CONFIG("Toggle Single Output", toggle_single_output)

/obj/item/mcobject/messaging/dispatch/examine(mob/user)
	. = ..()
	. += span_notice("Exact match mode: [exact_match ? "on" : "off"]")
	. += span_notice("Single output mode: [single_output ? "on" : "off"]")

/obj/item/mcobject/messaging/dispatch/proc/toggle_match(mob/user, obj/item/tool)
	exact_match = !exact_match
	to_chat(user, span_notice("You set the exact match mode of [src] to [exact_match ? "TRUE" : "FALSE"]"))
	log_message("match mode set to [exact_match] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/dispatch/proc/toggle_single_output(mob/user, obj/item/tool)
	single_output = !single_output
	to_chat(user, span_notice("You set the single output mode of [src] to [exact_match ? "TRUE" : "FALSE"]"))
	log_message("single output set to [single_output] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/dispatch/proc/dispatch(datum/mcmessage/input)
	fire(input)

/obj/item/mcobject/messaging/dispatch/linked_to(obj/item/mcobject/output, mob/user)
	var/filter = input(user, "Add filters for this connection?", "Configure Component") as null|text
	if(!filter)
		to_chat(user, span_notice("[src] will pass all messages to [output]."))
		return

	outgoing_filters[output.interface] = splittext(filter, ",")
	to_chat(user, span_notice("[src] will only pass messages that [exact_match ? "match" : "contain"] [filter] to [output]."))

/obj/item/mcobject/messaging/dispatch/proc/remove_message_filter(datum/mcinterface/source, datum/mcinterface/target)
	SIGNAL_HANDLER
	outgoing_filters -= target

/obj/item/mcobject/messaging/dispatch/proc/run_filter(datum/mcinterface/source, datum/mcinterface/outgoing, datum/mcmessage/input)
	SIGNAL_HANDLER

	if(!outgoing_filters[outgoing])
		return (single_output ? MCSEND_RETURN_AFTER : MCSEND_OK) //Not filtering this output, let anything pass

	var/command = input.cmd

	for (var/filter in outgoing_filters[outgoing])
		var/text_found = findtext(command, filter)
		if (exact_match)
			text_found = text_found && (length(command) == length(filter))
		if (text_found)
			return (single_output ? MCSEND_RETURN_AFTER : MCSEND_OK)

	return MCSEND_CANCEL

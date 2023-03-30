//Thank you mark
/obj/item/mcobject/messaging/regfind
	name = "regex find component"
	base_icon_state = "comp_regfind"
	icon_state = "comp_regfind"

	var/replace_message = FALSE
	var/expressionpatt = "\[a-zA-Z\]*"
	var/expressionTT = "\[a-zA-Z\]*"
	var/expressionflag = ""

/obj/item/mcobject/messaging/regfind/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("check string", check_str)
	MC_ADD_INPUT("set regex", set_regex)
	MC_ADD_CONFIG("Set Pattern", set_pattern_cfg)
	MC_ADD_CONFIG("Toggle Signal Replacing", toggle_replace)
	MC_ADD_CONFIG("Set Flags", set_flags_cfg)

/obj/item/mcobject/messaging/regfind/examine(mob/user)
	. = ..()
	. += span_notice("Current Expression: [strip_html(expressionTT)]")
	. += span_notice("Replace Signal is [replace_message ? "on.":"off."]")

/obj/item/mcobject/messaging/regfind/proc/set_regex(datum/mcmessage/input)
	expressionpatt = input.cmd
	expressionTT = ("[expressionpatt]/[expressionflag]")

/obj/item/mcobject/messaging/regfind/proc/set_pattern_cfg(mob/user, obj/item/tool)
	var/msg = input(user, "Enter pattern:", "Configure Component", expressionpatt)
	if(!msg)
		return
	expressionpatt = msg
	expressionTT =("[expressionpatt]/[expressionflag]")
	to_chat(user, span_notice("You set the pattern of [src] to [html_encode(expressionpatt)]."))
	log_message("pattern set to [expressionpatt] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/regfind/proc/toggle_replace(mob/user, obj/item/tool)
	replace_message = !replace_message
	to_chat(user, span_notice("You set [src] to [replace_message ? "forward it's own message":"forward the found string"]."))
	return TRUE

/obj/item/mcobject/messaging/regfind/proc/set_flags_cfg(mob/user, obj/item/tool)
	var/msg = input(user, "Enter flags:", "Configure Component", expressionflag)
	if(!msg)
		return
	expressionflag = msg
	expressionTT = ("[expressionpatt]/[expressionflag]")
	to_chat(user, span_notice("You set the flags of [src] to [html_encode(expressionflag)]."))
	log_message("expression flag set to [expressionflag] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/regfind/proc/check_str(datum/mcmessage/input)
	if(!expressionTT)
		return

	var/regex/R = new(expressionpatt, expressionflag)
	if(!R)
		return

	if(R.Find(input.cmd))
		if(replace_message)
			fire(stored_message, input)
		else
			input.cmd = R.match
			fire(input)

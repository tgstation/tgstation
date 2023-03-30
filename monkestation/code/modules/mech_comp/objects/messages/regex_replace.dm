//Thank you mark
/obj/item/mcobject/messaging/regreplace
	name = "regex replace component"
	base_icon_state = "comp_regrep"
	icon_state = "comp_regrep"

	var/expressionpatt = "original"
	var/expressionrepl = "replacement"
	var/expressionflag = "g"

/obj/item/mcobject/messaging/regreplace/Initialize(mapload)
	. = ..()
	MC_ADD_INPUT("replace string", check_str)
	MC_ADD_INPUT("set pattern", set_pattern)
	MC_ADD_INPUT("set replacement", set_replacement)
	MC_ADD_INPUT("set flags", set_flags)
	MC_ADD_CONFIG("Set Pattern", set_pattern_cfg)
	MC_ADD_CONFIG("Set Replacement", set_replacement_cfg)
	MC_ADD_CONFIG("Set Flags", set_flags_cfg)

/obj/item/mcobject/messaging/regreplace/examine(mob/user)
	. = ..()
	. += span_notice("Current Pattern: [html_encode(expressionpatt)]")
	. += span_notice("Current Replacement: [html_encode(expressionrepl)]")
	. += span_notice("Current Flags: [html_encode(expressionflag)]")
	. += span_notice("Your replacement string can contain $0-$9 to insert that matched group(things between parenthesis)")
	. += span_notice("$` will be replaced with the text that came before the match, and $' will be replaced by the text after the match.")
	. += span_notice("$0 or $& will be the entire matched string.")

/obj/item/mcobject/messaging/regreplace/proc/set_pattern(datum/mcmessage/input)
	expressionpatt = input.cmd

/obj/item/mcobject/messaging/regreplace/proc/set_replacement(datum/mcmessage/input)
	expressionrepl= input.cmd

/obj/item/mcobject/messaging/regreplace/proc/set_flags(datum/mcmessage/input)
	expressionflag = input.cmd

/obj/item/mcobject/messaging/regreplace/proc/set_pattern_cfg(mob/user, obj/item/tool)
	var/msg = input(user, "Enter pattern:", "Configure Component", expressionpatt)
	if(!msg)
		return
	expressionpatt = msg
	to_chat(user, span_notice("You set the pattern of [src] to [html_encode(expressionpatt)]."))
	log_message("pattern set to [expressionpatt] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/regreplace/proc/set_replacement_cfg(mob/user, obj/item/tool)
	var/msg = input(user, "Enter replacement:", "Configure Component", expressionrepl)
	if(!msg)
		return
	expressionrepl = msg
	to_chat(user, span_notice("You set the replacement of [src] to [html_encode(expressionrepl)]."))
	log_message("replacement set to [expressionrepl] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/regreplace/proc/set_flags_cfg(mob/user, obj/item/tool)
	var/msg = input(user, "Enter flags:", "Configure Component", expressionflag)
	if(!msg)
		return
	expressionflag = msg
	to_chat(user, span_notice("You set the flags of [src] to [html_encode(expressionflag)]."))
	log_message("expression flags set to [expressionflag] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

/obj/item/mcobject/messaging/regreplace/proc/check_str(datum/mcmessage/input)
	if(!expressionpatt)
		return
	var/regex/R = new(expressionpatt, expressionflag)
	if(!R)
		return

	var/mod = R.Replace(input.cmd, expressionrepl)
	mod = strip_html(mod)
	if(mod)
		input.cmd = mod
		fire(input)

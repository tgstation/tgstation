/datum/buildmode_mode/varedit
	key = "edit"
	// Varedit mode
	var/varholder = null
	var/valueholder = null

/datum/buildmode_mode/varedit/Destroy()
	varholder = null
	valueholder = null
	return ..()

/datum/buildmode_mode/varedit/show_help(client/builder)
	to_chat(builder, span_purple(boxed_message(
		"[span_bold("Select var(type) & value")] -> Right Mouse Button on buildmode button\n\
		[span_bold("Set var(type) & value")] -> Left Mouse Button on turf/obj/mob\n\
		[span_bold("Reset var's value")] -> Right Mouse Button on turf/obj/mob"))
	)

/datum/buildmode_mode/varedit/Reset()
	. = ..()
	varholder = null
	valueholder = null

/datum/buildmode_mode/varedit/change_settings(client/c)
	varholder = input(c, "Enter variable name:" ,"Name", "name")

	if(!vv_varname_lockcheck(varholder))
		return

	var/temp_value = c.vv_get_value()
	if(isnull(temp_value["class"]))
		Reset()
		to_chat(c, span_notice("Variable unset."))
		return
	valueholder = temp_value["value"]

/datum/buildmode_mode/varedit/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	if(isnull(varholder))
		to_chat(c, span_warning("Choose a variable to modify first."))
		return
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		if(object.vars.Find(varholder))
			if(object.vv_edit_var(varholder, valueholder) == FALSE)
				to_chat(c, span_warning("Your edit was rejected by the object."))
				return
			log_admin("Build Mode: [key_name(c)] modified [object.name]'s [varholder] to [valueholder]")
		else
			to_chat(c, span_warning("[initial(object.name)] does not have a var called '[varholder]'"))
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(object.vars.Find(varholder))
			var/reset_value = initial(object.vars[varholder])
			if(object.vv_edit_var(varholder, reset_value) == FALSE)
				to_chat(c, span_warning("Your edit was rejected by the object."))
				return
			log_admin("Build Mode: [key_name(c)] modified [object.name]'s [varholder] to [reset_value]")
		else
			to_chat(c, span_warning("[initial(object.name)] does not have a var called '[varholder]'"))


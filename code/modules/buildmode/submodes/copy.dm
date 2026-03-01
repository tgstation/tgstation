/datum/buildmode_mode/copy
	key = "copy"
	var/atom/movable/stored = null

/datum/buildmode_mode/copy/Destroy()
	stored = null
	return ..()

/datum/buildmode_mode/copy/show_help(client/builder)
	to_chat(builder, span_purple(boxed_message(
		"[span_bold("Spawn a copy of selected target")] -> Left Mouse Button on obj/turf/mob\n\
		[span_bold("Select target to copy")] -> Right Mouse Button on obj/mob"))
	)

/datum/buildmode_mode/copy/handle_click(client/c, params, obj/object)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/turf/T = get_turf(object)
		if(stored)
			duplicate_object(stored, spawning_location = T)
			log_admin("Build Mode: [key_name(c)] copied [stored] to [AREACOORD(object)]")
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if(ismovable(object)) // No copying turfs for now.
			to_chat(c, span_notice("[object] set as template."))
			stored = object

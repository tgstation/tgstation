// Blob Overmind Controls


/mob/eye/blob/ClickOn(atom/clicked_on, params) //Expand blob
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(clicked_on, params)
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(clicked_on)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		blob_click_alt(clicked_on)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(clicked_on)
		return
	var/turf/target_turf = get_turf(clicked_on)
	if(target_turf)
		expand_blob(target_turf)

/mob/eye/blob/MiddleClickOn(atom/clicked_on) //Rally spores
	. = ..()
	var/turf/target_turf = get_turf(clicked_on)
	if(target_turf)
		rally_spores(target_turf)

/mob/eye/blob/CtrlClickOn(atom/clicked_on) //Create a shield
	var/turf/target_turf = get_turf(clicked_on)
	if(target_turf)
		create_shield(target_turf)

/mob/eye/blob/proc/blob_click_alt(atom/clicked_on) //Remove a blob
	var/turf/target_turf = get_turf(clicked_on)
	if(target_turf)
		remove_blob(target_turf)

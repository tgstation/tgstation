// Blob Overmind Controls


/mob/eye/blob/ClickOn(atom/A, params) //Expand blob
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, params)
		return
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		ShiftClickOn(A)
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		blob_click_alt(A)
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		CtrlClickOn(A)
		return
	var/turf/T = get_turf(A)
	if(T)
		expand_blob(T)

/mob/eye/blob/MiddleClickOn(atom/A) //Rally spores
	. = ..()
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/eye/blob/CtrlClickOn(atom/A) //Create a shield
	var/turf/T = get_turf(A)
	if(T)
		create_shield(T)

/mob/eye/blob/proc/blob_click_alt(atom/A) //Remove a blob
	var/turf/T = get_turf(A)
	if(T)
		remove_blob(T)

// Blob Overmind Controls


/mob/camera/blob/ClickOn(atom/A, list/modifiers) //Expand blob
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		MiddleClickOn(A, list2params(modifiers))
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

/mob/camera/blob/MiddleClickOn(atom/A) //Rally spores
	. = ..()
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/camera/blob/CtrlClickOn(atom/A) //Create a shield
	var/turf/T = get_turf(A)
	if(T)
		create_shield(T)

/mob/camera/blob/proc/blob_click_alt(atom/A) //Remove a blob
	var/turf/T = get_turf(A)
	if(T)
		remove_blob(T)

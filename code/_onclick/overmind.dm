// Blob Overmind Controls


/mob/camera/blob/CtrlClickOn(atom/A) // Expand blob
	var/turf/T = get_turf(A)
	if(T)
		expand_blob(T)

/mob/camera/blob/MiddleClickOn(atom/A) // Rally spores
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/camera/blob/AltClickOn(atom/A) // Create a shield
	var/turf/T = get_turf(A)
	if(T)
		create_shield(T)
<<<<<<< HEAD
// Blob Overmind Controls


/mob/camera/blob/ClickOn(var/atom/A, var/params) //Expand blob
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return
	var/turf/T = get_turf(A)
	if(T)
		expand_blob(T)

/mob/camera/blob/MiddleClickOn(atom/A) //Rally spores
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/camera/blob/CtrlClickOn(atom/A) //Create a shield
	var/turf/T = get_turf(A)
	if(T)
		create_shield(T)

/mob/camera/blob/AltClickOn(atom/A) //Remove a blob
	var/turf/T = get_turf(A)
	if(T)
		remove_blob(T)
=======
// Blob Overmind Controls


/mob/camera/blob/CtrlClickOn(var/atom/A) // Expand blob
	var/turf/T = get_turf(A)
	if(T)
		expand_blob(T)

/mob/camera/blob/MiddleClickOn(var/atom/A) // Rally spores
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/camera/blob/AltClickOn(var/atom/A) // Create a shield
	var/turf/T = get_turf(A)
	if(T)
		create_shield(T)

mob/camera/blob/DblClickOn(var/atom/A) //Teleport view to another blob
	var/turf/T = get_turf(A)

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)
		return
	else
		usr.loc = T
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

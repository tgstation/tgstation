
//**************************************************************
//
// Blobs 
// -----------
// TODO: Move the rest of blob code here.
//
//**************************************************************

/mob/camera/blob/CtrlClickOn(atom/target)
	target = get_turf(target)
	if(target) expand_blob(target)
	return

/mob/camera/blob/MiddleClickOn(atom/target)
	target = get_turf(target)
	if(target) rally_spores(target)
	return

/mob/camera/blob/AltClickOn(atom/target)
	target = get_turf(target)
	if(target) create_shield(target)
	return

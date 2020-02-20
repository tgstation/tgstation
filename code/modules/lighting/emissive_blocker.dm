/// Internal atom that the only purpose is copying the appearance of a target on to the blocker plane.
/// If you are using it for anything besides that, you are using this very wrong.
/atom/movable/emissive_blocker
	name = ""
	plane = EMISSIVE_BLOCKER_PLANE
	layer = EMISSIVE_BLOCKER_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	//Why?
	//render_targets copy the transform of the target as well, but vis_contents also applies the transform
	//to what's in it. Applying RESET_TRANSFORM here makes vis_contents not apply the transform.
	//Since only render_target handles transform we don't get any applied transform "stacking"
	appearance_flags = RESET_TRANSFORM

/atom/movable/emissive_blocker/Initialize(mapload, source)
	. = ..()
	verbs.Cut() //Cargo culting from lighting object, this maybe affects memory usage?

	render_source = source

/atom/movable/emissive_blocker/ex_act(severity)
	return FALSE

/atom/movable/emissive_blocker/singularity_act()
	return

/atom/movable/emissive_blocker/singularity_pull()
	return

/atom/movable/emissive_blocker/blob_act()
	return

/atom/movable/emissive_blocker/onTransitZ()
	return

//Prevents people from moving these after creation, because they shouldn't be.
/atom/movable/emissive_blocker/forceMove(atom/destination, no_tp=FALSE, harderforce = FALSE)
	if(harderforce)
		. = ..()

/atom/movable/screen/plane_master/camera_static
	name = "Camera static"
	documentation = "Holds camera static images. Usually only visible to people who can well, see static.\
		<br>We use images rather then vis contents because they're lighter on maptick, and maptick sucks butt."
	plane = CAMERA_STATIC_PLANE

/atom/movable/screen/plane_master/camera_static/show_to(mob/mymob)
	. = ..()
	if(!.)
		return
	var/datum/hud/our_hud = home.our_hud
	if(isnull(our_hud))
		return

	// We'll hide the slate if we're not seeing through a camera eye
	// This can call on a cycle cause we don't clear in hide_from
	// Yes this is the best way of hooking into the hud, I hate myself too
	RegisterSignal(our_hud, COMSIG_HUD_EYE_CHANGED, PROC_REF(eye_changed), override = TRUE)
	eye_changed(our_hud, null, our_hud.mymob?.canon_client?.eye)

/atom/movable/screen/plane_master/camera_static/proc/eye_changed(datum/hud/source, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER

	if(!isaicamera(new_eye))
		if(!force_hidden)
			hide_plane(source.mymob)
		return

	if(force_hidden)
		unhide_plane(source.mymob)

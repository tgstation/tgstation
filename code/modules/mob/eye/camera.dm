// CAMERA EYE
//
// An invisible (no icon) mob that advanced cameras (like the AI) control to look around the station with.
// It streams chunks as it moves around, which will show it what the user can and cannot see.
/mob/eye/camera
	name = "Inactive Camera Eye"
	icon = 'icons/mob/eyemob.dmi'
	icon_state = "generic_camera"

	invisibility = INVISIBILITY_MAXIMUM
	interaction_range = INFINITY
	var/list/visibleCameraChunks = list()
	var/use_static = TRUE
	var/static_visibility_range = 16

// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = 0
	anchored = 1
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = 0
	see_in_dark = 7
	invisibility = 100 // with 101 we can't see emotes, view() and range() don't include invisible objects

	move_on_shuttle = 0

/mob/camera/experience_pressure_difference()
	return
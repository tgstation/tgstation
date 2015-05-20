// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = 0
	anchored = 1
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = 0
	see_in_dark = 7
	invisibility = 101 // No one can see us

	move_on_shuttle = 0

/mob/camera/experience_pressure_difference()
	return

/mob/camera/Destroy()
	..()
	del(src)

/mob/camera/Login()
	..()
	update_interface()
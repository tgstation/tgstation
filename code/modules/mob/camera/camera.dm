// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	see_in_dark = 7
	invisibility = INVISIBILITY_ABSTRACT // No one can see us
	sight = SEE_SELF
	move_on_shuttle = FALSE
	var/call_life = FALSE //TRUE if Life() should be called on this camera every tick of the mobs subystem, as if it were a living mob

/mob/camera/Initialize()
	. = ..()
	if(call_life)
		GLOB.living_cameras += src

/mob/camera/Destroy()
	. = ..()
	if(call_life)
		GLOB.living_cameras -= src

/mob/camera/experience_pressure_difference()
	return

/mob/camera/forceMove(atom/destination)
	loc = destination

/mob/camera/emote(act, m_type=1, message = null, intentional = FALSE)
	return

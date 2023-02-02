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
	/// Toggles if the camera can use emotes
	var/has_emotes = FALSE

/mob/camera/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)

/mob/camera/experience_pressure_difference()
	return

/mob/camera/canUseStorage()
	return FALSE

/mob/camera/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/camera/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))

/mob/camera/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	z_move_flags |= ZMOVE_IGNORE_OBSTACLES  //cameras do not respect these FLOORS you speak so much of
	return ..()

/mob/camera/emote(act, m_type=1, message = null, intentional = FALSE, force_silence = FALSE)
	if(has_emotes)
		return ..()
	return FALSE

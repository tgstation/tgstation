/// Eye mob, used by cameras and overminds such as blobs.
/mob/eye
	name = "eye mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT // No one can see us
	sight = SEE_SELF
	status_flags = NONE
	/// Toggles if the eye can move on shuttles
	var/move_on_shuttle = FALSE
	/// Toggles if the eye can use emotes
	var/has_emotes = FALSE

/mob/eye/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_GODMODE, INNATE_TRAIT)
	SSpoints_of_interest.make_point_of_interest(src)
	if(!move_on_shuttle)
		ADD_TRAIT(src, TRAIT_BLOCK_SHUTTLE_MOVEMENT, INNATE_TRAIT)

/mob/eye/experience_pressure_difference()
	return

/mob/eye/canUseStorage()
	return FALSE

/mob/eye/up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/eye/down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))

/mob/eye/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	z_move_flags |= ZMOVE_IGNORE_OBSTACLES  //cameras do not respect these FLOORS you speak so much of
	return ..()

/mob/eye/emote(act, m_type=1, message = null, intentional = FALSE, force_silence = FALSE)
	if(has_emotes)
		return ..()
	return FALSE

/mob/eye/update_sight()
	lighting_color_cutoffs = list(lighting_cutoff_red, lighting_cutoff_green, lighting_cutoff_blue)
	return ..()

/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	if(SEND_SIGNAL(src, COMSIG_LIVING_CAN_ALLOW_THROUGH, mover, border_dir) & COMPONENT_LIVING_PASSABLE)
		return TRUE
	return ..()

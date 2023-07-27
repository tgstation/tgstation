// Signals for /mob/living

/mob/living/CanAllowThrough(atom/movable/mover, border_dir)
	if(SEND_SIGNAL(src, COMSIG_LIVING_CAN_ALLOW_THROUGH, mover, border_dir) & COMPONENT_LIVING_PASSABLE)
		return TRUE
	return ..()

/mob/living/set_pull_offsets(mob/living/pull_target, grab_state)
	. = ..()
	SEND_SIGNAL(pull_target, COMSIG_LIVING_SET_PULL_OFFSET, grab_state)

/mob/living/reset_pull_offsets(mob/living/pull_target, override)
	. = ..()
	SEND_SIGNAL(pull_target, COMSIG_LIVING_RESET_PULL_OFFSETS, override)

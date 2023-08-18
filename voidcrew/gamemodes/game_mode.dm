/datum/game_mode/check_finished(force_ending)
	if(SSovermap.jump_mode == BS_JUMP_COMPLETED)
		return TRUE
	..()

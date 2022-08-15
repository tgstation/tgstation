/datum/idle_behavior/idle_monkey/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(DT_PROB(5, delta_time))
		INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick("screech"))
	else if(DT_PROB(1, delta_time))
		INVOKE_ASYNC(living_pawn, /mob.proc/emote, pick("scratch","jump","roll","tail"))

/datum/idle_behavior/idle_slime_playful
	///Chance that the mob random walks per second
	var/walk_chance = 25
	///list of possible play_type
	var/list/playing_types = list(
		/datum/ai_behavior/slime_stacker,
	)

/datum/idle_behavior/idle_slime_playful/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(LAZYLEN(living_pawn.do_afters))
		return

	if(SPT_PROB(walk_chance, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)

	if(prob(3)) //change this as we see fit
		controller.queue_behavior(pick(playing_types))
	else if (prob(4))
		SEND_SIGNAL(controller.pawn, EMOTION_BUFFER_SPEAK_FROM_BUFFER)

/datum/idle_behavior/idle_monkey
	///Emotes that will be played commonly during idle behavior.
	var/list/common_emotes = list(
		"screech",
		"roar",
	)
	///Emotes that will be played rarely during idle behavior.
	var/list/rare_emotes = list(
		"scratch",
		"jump",
		"roll",
		"tail",
	)

/datum/idle_behavior/idle_monkey/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn

	if(SPT_PROB(25, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
	else if(SPT_PROB(5, seconds_per_tick))
		INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(common_emotes))
	else if(SPT_PROB(1, seconds_per_tick))
		INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(rare_emotes))

/datum/idle_behavior/idle_monkey/pun_pun
	common_emotes = list(
		"tunesing",
		"dance",
		"bow",
	)
	rare_emotes = list(
		"clear",
		"sign",
		"tail",
	)

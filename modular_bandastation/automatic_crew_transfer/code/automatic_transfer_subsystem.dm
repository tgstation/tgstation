SUBSYSTEM_DEF(automatic_transfer)
	name = "Automatic Transfer"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	/// Time when next crew transfer vote will run
	COOLDOWN_DECLARE(automatic_crew_transfer_vote_cooldown)

/datum/controller/subsystem/automatic_transfer/Initialize()
	if(!CONFIG_GET(flag/enable_automatic_crew_transfer))
		flags |= SS_NO_FIRE
		return SS_INIT_NO_NEED

	if(SSticker.current_state < GAME_STATE_PLAYING)
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_starting))
	else if(SSticker.current_state == GAME_STATE_PLAYING)
		on_round_starting()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/automatic_transfer/fire(resumed)
	if(COOLDOWN_FINISHED(src, automatic_crew_transfer_vote_cooldown))
		start_crew_transfer_vote()

/datum/controller/subsystem/automatic_transfer/Recover()
	automatic_crew_transfer_vote_cooldown = SSautomatic_transfer.automatic_crew_transfer_vote_cooldown

/datum/controller/subsystem/automatic_transfer/proc/on_round_starting(datum/controller/subsystem/ticker)
	SIGNAL_HANDLER

	COOLDOWN_START(src, automatic_crew_transfer_vote_cooldown, CONFIG_GET(number/automatic_crew_transfer_vote_delay))

/datum/controller/subsystem/automatic_transfer/proc/start_crew_transfer_vote()
	PRIVATE_PROC(TRUE)

	SSvote.initiate_vote(/datum/vote/crew_transfer, "Automatic Crew Transfer", forced = TRUE)
	COOLDOWN_START(src, automatic_crew_transfer_vote_cooldown, CONFIG_GET(number/automatic_crew_transfer_vote_interval))

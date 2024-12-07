SUBSYSTEM_DEF(automatic_transfer)
	name = "Automatic Transfer"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME
	/// Id of planned crew transfer timer
	var/crew_transfer_timer_id

/datum/controller/subsystem/automatic_transfer/Initialize()
	if(CONFIG_GET(flag/enable_automatic_crew_transfer))
		setup_automatic_crew_transfer()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/automatic_transfer/proc/plan_crew_transfer_vote(delay = CONFIG_GET(number/automatic_crew_transfer_vote_interval))
	if(!CONFIG_GET(flag/enable_automatic_crew_transfer))
		return

	if(!crew_transfer_timer_id)
		crew_transfer_timer_id = addtimer(CALLBACK(src, PROC_REF(start_crew_transfer_vote)), delay)

/datum/controller/subsystem/automatic_transfer/proc/setup_automatic_crew_transfer()
	PRIVATE_PROC(TRUE)

	if(SSticker.current_state < GAME_STATE_PLAYING)
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(plan_crew_transfer_vote), CONFIG_GET(number/automatic_crew_transfer_vote_delay))
	else if(SSticker.current_state == GAME_STATE_PLAYING)
		plan_crew_transfer_vote(max(0,  CONFIG_GET(number/automatic_crew_transfer_vote_delay) - (world.time - SSticker.round_start_time)))

/datum/controller/subsystem/automatic_transfer/proc/start_crew_transfer_vote()
	PRIVATE_PROC(TRUE)

	SSvote.initiate_vote(/datum/vote/crew_transfer, "Automatic Crew Transfer", forced = TRUE)
	crew_transfer_timer_id = null

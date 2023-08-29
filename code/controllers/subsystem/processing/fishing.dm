///Super fast to minimize output lag, but it doesn't fire unless someone is actually fishing.
PROCESSING_SUBSYSTEM_DEF(fishing)
	name = "Fishing"
	wait = 0.5 SECONDS
	can_fire = FALSE

/datum/controller/subsystem/processing/fishing/proc/begin_minigame_process(datum/fishing_challenge/minigame)
	if(!length(processing))
		can_fire = TRUE
		//Prevents the subsystem from rapid firing since it must have been a while since it last fired.
		update_nextfire(reset_time = TRUE)
	START_PROCESSING(src, minigame)

/datum/controller/subsystem/processing/fishing/proc/end_minigame_process(datum/fishing_challenge/minigame)
	STOP_PROCESSING(src, minigame)
	if(!length(processing))
		can_fire = FALSE

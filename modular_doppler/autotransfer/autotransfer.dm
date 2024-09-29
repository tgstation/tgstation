#define NO_MAXVOTES_CAP -1

SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/starttime
	var/targettime
	var/voteinterval
	var/maxvotes
	var/curvotes = 0

/datum/controller/subsystem/autotransfer/Initialize()
	if(!CONFIG_GET(flag/autotransfer)) //Autotransfer voting disabled.
		can_fire = FALSE
		return SS_INIT_NO_NEED

	var/init_vote = CONFIG_GET(number/vote_autotransfer_initial)
	starttime = REALTIMEOFDAY
	targettime = starttime + init_vote
	voteinterval = CONFIG_GET(number/vote_autotransfer_interval)
	maxvotes = CONFIG_GET(number/vote_autotransfer_maximum)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/Recover()
	starttime = SSautotransfer.starttime
	voteinterval = SSautotransfer.voteinterval
	curvotes = SSautotransfer.curvotes

/datum/controller/subsystem/autotransfer/fire()
	if(REALTIMEOFDAY < targettime)
		return
	if(maxvotes == NO_MAXVOTES_CAP || maxvotes > curvotes)
		SSvote.initiate_vote(/datum/vote/transfer_vote, "automatic transfer", forced = TRUE)
		targettime = targettime + voteinterval
		curvotes++
	else
		SSshuttle.autoEnd()

/**
 * At shift start, pulls the autotransfer interval from config and applies
 *
 * Arguments:
 * * real_round_shift_time - World time the round left the pregame lobby
 */
/datum/controller/subsystem/autotransfer/proc/new_shift(real_round_start_time)
	var/init_vote = CONFIG_GET(number/vote_autotransfer_initial) // Check if an admin has manually set an override in the pre-game lobby
	starttime = real_round_start_time
	targettime = starttime + init_vote
	log_game("Autotransfer enabled, first vote in [DisplayTimeText(targettime - starttime)]")
	message_admins("Autotransfer enabled, first vote in [DisplayTimeText(targettime - starttime)]")

#undef NO_MAXVOTES_CAP

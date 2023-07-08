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
	starttime = world.realtime // Skyrat edit
	targettime = starttime + init_vote
	voteinterval = CONFIG_GET(number/vote_autotransfer_interval)
	maxvotes = CONFIG_GET(number/vote_autotransfer_maximum)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/Recover()
	starttime = SSautotransfer.starttime
	voteinterval = SSautotransfer.voteinterval
	curvotes = SSautotransfer.curvotes

/datum/controller/subsystem/autotransfer/fire()
	if(world.realtime < targettime)
		return
	if(maxvotes == NO_MAXVOTES_CAP || maxvotes > curvotes)
		SSvote.initiate_vote(/datum/vote/transfer_vote, "automatic transfer", forced = TRUE)
		targettime = targettime + voteinterval
		curvotes++
	else
		SSshuttle.autoEnd()

#undef NO_MAXVOTES_CAP

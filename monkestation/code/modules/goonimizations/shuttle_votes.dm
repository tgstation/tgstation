
SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/starttime
	var/targettime

/datum/controller/subsystem/autotransfer/Initialize(timeofday)
	starttime = world.time
	targettime = starttime + 1 MINUTES

	return SS_INIT_SUCCESS

/datum/controller/subsystem/autotransfer/fire()
	if(world.time > targettime)
		SSvote.initiate_vote(/datum/vote/shuttle_call, "automatic shuttle vote")
		targettime = targettime + 20 MINUTES

/datum/vote/shuttle_call
	name = "Call Shuttle"
	message = "Should we go home?!"

/datum/vote/shuttle_call/can_be_initiated(mob/by_who, forced = FALSE)
	if(started_time)
		var/next_allowed_time = SSautotransfer.targettime
		if(next_allowed_time > world.time && !forced)
			message = "A vote was initiated recently. You must wait [DisplayTimeText(next_allowed_time - world.time)] before a shuttle vote can happen!"
			return FALSE

	message = initial(message)
	. = ..()


/datum/vote/shuttle_call/New()
	. = ..()
	default_choices = list("Yes", "No", "Yes (No Recall)")


/datum/vote/shuttle_call/finalize_vote(winning_option)
	if(winning_option == "No")
		return

	if(winning_option == "Yes (No Recall)")
		SSshuttle.admin_emergency_no_recall = TRUE
		SSshuttle.emergency.mode = SHUTTLE_IDLE
	SSshuttle.emergency.request()

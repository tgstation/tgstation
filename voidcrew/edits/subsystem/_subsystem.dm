/datum/controller/subsystem/processing/station
	can_fire = FALSE

/datum/controller/subsystem/processing/station/Initialize()
	//Initialize the station's announcer datum and nothing else
	announcer = new announcer()
	return SS_INIT_SUCCESS

// We do not want paychecks, we want people to make money themselves legitimately
/datum/controller/subsystem/economy
	can_fire = FALSE

//We do not have Antagonists, there is no point in processing this.
/datum/controller/subsystem/traitor
	can_fire = FALSE

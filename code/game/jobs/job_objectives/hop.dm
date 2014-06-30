/*
DONE HoP : Reassign at least 10 IDs (naturally fresh IDs don't count to avoid cheating)
TODO HoP : Finish the round with -item that a captain would be wearing/owning-. For instance TEH DISK!1!
TODO HoP : Finish the round with at least one crewmember alive and extracted in every department
TODO HoP : Ian must be alive at round end (a classic)
*/

//////////////////////////////////////
// REASSIGN IDs
//////////////////////////////////////

#define JOBJ_REASSIGN        /datum/job_objective/reassign_id
#define ID_REASSIGN_COOLDOWN 30 SECONDS

/datum/job_objective/reassign_id
	completion_payment =200
	units_requested    = 10
	per_unit           =  1

/datum/job_objective/reassign_id/get_description()
	return "Reassign an ID. ([units_completed] created.)"



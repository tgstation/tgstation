/datum/job/recovered_crew
	policy_override = "Recovered Crew"
	faction = FACTION_STATION

/datum/job/recovered_crew/doctor
	title = JOB_LOSTCREW_MEDICAL
	supervisors = SUPERVISOR_CMO

/datum/job/recovered_crew/engineer
	title = JOB_LOSTCREW_ENGINEER
	supervisors = SUPERVISOR_CE

/datum/job/recovered_crew/security
	title = JOB_LOSTCREW_SECURITY
	supervisors = SUPERVISOR_HOS

/datum/job/recovered_crew/cargo
	title = JOB_LOSTCREW_CARGO
	supervisors = SUPERVISOR_QM

/datum/job/recovered_crew/scientist
	title = JOB_LOSTCREW_SCIENCE
	supervisors = SUPERVISOR_RD

/datum/job/recovered_crew/civillian
	title = JOB_LOSTCREW_CIVILLIAN
	supervisors = SUPERVISOR_HOP

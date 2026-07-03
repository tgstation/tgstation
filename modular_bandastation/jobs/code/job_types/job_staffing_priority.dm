#define STAFFING_PRIORITY_CRITICAL 1
#define STAFFING_PRIORITY_VERY_IMPORTANT 2
#define STAFFING_PRIORITY_IMPORTANT 3
#define STAFFING_PRIORITY_MODERATE 4
#define STAFFING_PRIORITY_MINOR 5
#define STAFFING_PRIORITY_NEGLIGIBLE 6

/proc/cmp_job_staffing_priority(datum/job/A, datum/job/B)
	if(A.staffing_priority == B.staffing_priority)
		if(A.spawn_positions <= 0 && B.spawn_positions <= 0)
			return 0

		if(A.spawn_positions <= 0)
			return 1

		if(B.spawn_positions <= 0)
			return -1

		return cmp_numeric_asc(A.current_positions / A.spawn_positions, B.current_positions / B.spawn_positions)

	return cmp_numeric_asc(A.staffing_priority, B.staffing_priority)

/datum/job
	/// Determines in which priority this job is assigned to players during roundstart
	var/staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

// MARK: Captain
/datum/job/captain
	staffing_priority = STAFFING_PRIORITY_CRITICAL

// MARK: Silicons
/datum/job/ai
	staffing_priority = STAFFING_PRIORITY_VERY_IMPORTANT

/datum/job/cyborg
	staffing_priority = STAFFING_PRIORITY_MINOR

// MARK: Security
/datum/job/head_of_security
	staffing_priority = STAFFING_PRIORITY_IMPORTANT

/datum/job/warden
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/detective
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/security_officer
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/prisoner
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

// MARK: Engineering
/datum/job/chief_engineer
	staffing_priority = STAFFING_PRIORITY_IMPORTANT

/datum/job/station_engineer
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/atmospheric_technician
	staffing_priority = STAFFING_PRIORITY_MINOR

// MARK: Medical
/datum/job/chief_medical_officer
	staffing_priority = STAFFING_PRIORITY_IMPORTANT

/datum/job/doctor
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/chemist
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/paramedic
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/coroner
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

// MARK: Service
/datum/job/head_of_personnel
	staffing_priority = STAFFING_PRIORITY_IMPORTANT

/datum/job/bartender
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

/datum/job/botanist
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/clown
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/cook
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/curator
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

/datum/job/janitor
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

/datum/job/mime
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/psychologist
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

/datum/job/chaplain
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

// MARK: Science
/datum/job/research_director
	staffing_priority = STAFFING_PRIORITY_IMPORTANT

/datum/job/scientist
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/roboticist
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/geneticist
	staffing_priority = STAFFING_PRIORITY_MINOR

// MARK: Cargo
/datum/job/quartermaster
	staffing_priority = STAFFING_PRIORITY_IMPORTANT

/datum/job/cargo_technician
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

/datum/job/bitrunner
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/shaft_miner
	staffing_priority = STAFFING_PRIORITY_MODERATE

/datum/job/explorer
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

// MARK: Justice
/datum/job/magistrate
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/lawyer
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

// MARK: Nanotrasen Representation
/datum/job/nanotrasen_representative
	staffing_priority = STAFFING_PRIORITY_MINOR

/datum/job/blueshield
	staffing_priority = STAFFING_PRIORITY_NEGLIGIBLE

#undef STAFFING_PRIORITY_CRITICAL
#undef STAFFING_PRIORITY_VERY_IMPORTANT
#undef STAFFING_PRIORITY_IMPORTANT
#undef STAFFING_PRIORITY_MODERATE
#undef STAFFING_PRIORITY_MINOR
#undef STAFFING_PRIORITY_NEGLIGIBLE

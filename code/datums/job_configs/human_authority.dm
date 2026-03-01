/// Whether if the job should whitelist humans, whitelist nonhumans, or neither
/datum/job_config_type/human_authority
	name = JOB_CONFIG_HUMAN_AUTHORITY
	datum_var_name = "human_authority"

/datum/job_config_type/human_authority/validate_value(value)
	if(value == JOB_AUTHORITY_HUMANS_ONLY)
		return TRUE

	if(value == JOB_AUTHORITY_NON_HUMANS_ALLOWED)
		return TRUE

	return FALSE

/datum/job_config_type/human_authority/validate_entry(datum/job/occupation)
	return occupation.job_flags & JOB_HEAD_OF_STAFF


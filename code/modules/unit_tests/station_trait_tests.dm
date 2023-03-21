/// This test spawns various station traits and looks through them to see if there's any errors.
/datum/unit_test/station_traits

/datum/unit_test/station_traits/Run()
	var/datum/station_trait/cybernetic_revolution/cyber_trait = allocate(/datum/station_trait/cybernetic_revolution)
	for(var/datum/job/job in subtypesof(/datum/job))
		if(!(initial(job.job_flags) & JOB_CREW_MEMBER))
			continue
		if(!(job in cyber_trait.job_to_cybernetic))
			TEST_FAIL("Job [job] does not have an assigned cybernetic for [cyber_trait.type] station trait.")

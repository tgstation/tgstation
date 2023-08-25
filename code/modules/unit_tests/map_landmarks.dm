/// Tests that [/datum/job/proc/get_default_roundstart_spawn_point] returns a landmark from all joinable jobs.
/datum/unit_test/job_roundstart_spawnpoints

/datum/unit_test/job_roundstart_spawnpoints/Run()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(job.spawn_positions <= 0)
			// Zero spawn positions means we don't need to care if they don't have a roundstart landmark
			continue
		if(job.get_default_roundstart_spawn_point())
			continue

		TEST_FAIL("Job [job.title] ([job.type]) has no default roundstart spawn landmark.")

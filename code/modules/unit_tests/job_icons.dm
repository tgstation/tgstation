/// Tests that all jobs that could be part of the crew manifest (and therefore on the observer menu) has a TGUI icon to display.
/datum/unit_test/job_icons

/datum/unit_test/job_icons/Run()
	for(var/datum/job/job as anything in subtypesof(/datum/job))
		if(!(job::job_flags & JOB_CREW_MANIFEST))
			continue
		if(isnull(job::tgui_icon))
			TEST_FAIL("[job::title] does not have a valid job icon.")

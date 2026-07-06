/// Tests to ensure each job with a display order have a unique index.
/datum/unit_test/job_display_order

/datum/unit_test/job_display_order/Run()
	var/list/unique_indexes = list()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		var/jobs_display_order = job.display_order
		if(jobs_display_order == JOB_DISPLAY_ORDER_DEFAULT) // Clearly we dont care how its sorted. Mabye we should? Shrug
			continue
		if(!unique_indexes[jobs_display_order])
			unique_indexes[jobs_display_order] = job
		else
			TEST_FAIL("[job] has the same index as [unique_indexes[jobs_display_order]] of: [jobs_display_order]..")

/// Tests to ensure each department with a display order have a unique index.
/datum/unit_test/department_display_order

/datum/unit_test/department_display_order/Run()
	var/list/unique_indexes = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments_by_type)
		var/departments_display_order = department.display_order
		if(!unique_indexes[departments_display_order])
			unique_indexes[departments_display_order] = department
		else
			TEST_FAIL("[department] has the same index as [unique_indexes[departments_display_order]] of: [departments_display_order].")

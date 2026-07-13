/// Tests to ensure each job with a display order has a unique index.
/datum/unit_test/job_display_order

/datum/unit_test/job_display_order/Run()
	var/alist/unique_indexes = alist()
	// joinable_occupations instead of all_occupations because human_ai and ai have the same index otherwise... Is this a source of flaky fails..? Unsure
	for(var/datum/job/job in SSjob.joinable_occupations)
		var/jobs_display_order = job.display_order_with_department()
		if(!jobs_display_order || !job.display_order)
			TEST_FAIL("[job] has no set display order.")
		else if(unique_indexes["[jobs_display_order]"])
			TEST_FAIL("[job] has the same index as [unique_indexes["[jobs_display_order]"]] of: [jobs_display_order].")
		else
			unique_indexes["[jobs_display_order]"] = job

/// Tests to ensure each department has a unique index.
/datum/unit_test/department_display_order

/datum/unit_test/department_display_order/Run()
	var/alist/unique_indexes = alist()
	for(var/datum/job_department/department in SSjob.joinable_departments)
		var/departments_display_order = department.display_order
		if(!departments_display_order)
			TEST_FAIL("[department] has no set display order.")
		else if(unique_indexes["[departments_display_order]"])
			TEST_FAIL("[department] has the same index as [unique_indexes["[departments_display_order]"]] of: [departments_display_order].")
		else
			unique_indexes["[departments_display_order]"] = department

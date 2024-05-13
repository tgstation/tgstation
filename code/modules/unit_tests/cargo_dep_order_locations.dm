/datum/unit_test/cargo_dep_order_locations

/datum/unit_test/cargo_dep_order_locations/Run()
	for(var/datum/job_department/department_to_check in subtypesof(/datum/job_department))
		if(isnull(department_to_check.department_delivery_areas) || !length(department_to_check.department_delivery_areas))
			continue
		if(check_valid_delivery_location(department_to_check))
			continue
		else
			TEST_FAIL("[department_to_check.type] failed to find a valid delivery location on this map.")


/datum/unit_test/cargo_dep_order_locations/proc/check_valid_delivery_location(/datum/job_department/department_to_check)
	for(var/delivery_area_type in department_delivery_areas)
		if(GLOB.areas_by_type[delivery_area_type])
			return TRUE
	return FALSE

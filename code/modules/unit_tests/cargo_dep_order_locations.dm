/datum/unit_test/cargo_dep_order_locations

/datum/unit_test/cargo_dep_order_locations/Run()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/delivery_areas = department.department_delivery_areas
		if(!length(delivery_areas))
			continue
		if(check_valid_delivery_location(delivery_areas))
			continue
		TEST_FAIL("[department.type] failed to find a valid delivery location on this map.")


/datum/unit_test/cargo_dep_order_locations/proc/check_valid_delivery_location(list/delivery_areas)
	for(var/delivery_area_type in delivery_areas)

		if(GLOB.areas_by_type[delivery_area_type])
			return TRUE
	return FALSE

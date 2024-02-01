/datum/round_event/brand_intelligence
	var/static/list/potential_areas = list(
		/area/station/hallway = 10,
		/area/station/service = 10,
		/area/station/engineering = 5,
		/area/station/cargo = 5,
		/area/station/science = 5,
		/area/station/medical = 1,
		/area/station/security = 1
	)
	var/static/list/forbidden_areas = typecacheof(list(/area/station/security/checkpoint))

/datum/round_event/brand_intelligence/setup()
	var/department = pick_weight(potential_areas)
	var/list/department_typecache = typecacheof(department) - forbidden_areas
	//select our origin machine (which will also be the type of vending machine affected.)
	for(var/obj/machinery/vending/vendor in GLOB.machines)
		if(!is_station_level(vendor.z) || !vendor.density)
			continue
		if(chosen_vendor_type && !istype(vendor, chosen_vendor_type))
			continue
		var/area/vendor_area = get_area(vendor)
		if(!is_type_in_typecache(vendor_area, department_typecache))
			continue
		vending_machines += vendor
	if(!length(vending_machines)) //If somehow there are still no elligible vendors, give up.
		kill()
		return
	origin_machine = pick_n_take(vending_machines)
	setup = TRUE //MONKESTATION ADDITION

/datum/experiment/exploration_scan
	name = "Exploration Experiment"
	description = "An experiment requiring drone exploration to progress"
	exp_tag = "Exploration"
	performance_hint = "Find a site with specific characteristics and perform the scan."
	// Site type, scan needs to be of that type
	var/required_site_type
	// Condition type, scan needs to be of site with this condition
	var/required_condition
	// Required scan type
	var/required_scan_type = EXOSCAN_POINT

/datum/experiment/exploration_scan/is_complete()
	for(var/datum/exploration_site/site in GLOB.exploration_sites)
		switch(required_scan_type)
			if(EXOSCAN_DEEP)
				if(!site.deep_scan_complete)
					continue
			if(EXOSCAN_POINT)
				if(!site.point_scan_complete)
					continue
		if(required_site_type && !istype(site,required_site_type))
			continue
		if(required_condition && !(locate(required_condition) in site.scan_conditions))
			continue
		return TRUE
	return FALSE

/datum/experiment/exploration_scan/perform_experiment_actions(datum/component/experiment_handler/experiment_handler)
	return is_complete()

/datum/experiment/exploration_scan/actionable(datum/component/experiment_handler/experiment_handler)
	return !is_complete()

/datum/experiment/exploration_scan/asteroid_belt
	name = "Scan Asteroid Belt"
	description = "We're looking for a site to test our asteroid blasting caps. Perform point scan of one."
	required_site_type = /datum/exploration_site/asteroid_belt
	required_scan_type = EXOSCAN_POINT

/datum/experiment/exploration_scan/black_hole
	name = "Deep scan a black hole"
	description = "We require more research data on black holes, perform deep scan of a system affected by one."
	required_condition = /datum/scan_condition/black_hole
	required_scan_type = EXOSCAN_DEEP

/datum/experiment/exploration_scan/random
	name = "Random Exoscan Experiment"
	description = "We need scan data of specific site type"
	/// If not null the required_site_type will be picked from this list
	var/list/possible_random_conditions
	/// If not null the required_condition will be picked from this list
	var/list/possible_random_site_types

/datum/experiment/exploration_scan/random/New(datum/techweb/techweb)
	. = ..()
	if(length(possible_random_site_types))
		required_site_type = pick(possible_random_site_types)
	if(length(possible_random_conditions))
		required_condition = pick(possible_random_conditions)
	var/list/name_parts = list()
	name_parts += "[required_scan_type] scan of"
	if(required_site_type)
		var/datum/exploration_site/site = required_site_type
		name_parts += initial(site.name)
	else
		name_parts += "site"
	if(required_condition)
		var/datum/scan_condition/condition = required_condition
		name_parts += "affected by \the [initial(condition.name)]"
	name = capitalize(name_parts.Join(""))
	description = name

/datum/experiment/exploration_scan/random/condition
	possible_random_conditions = list(/datum/scan_condition/asteroid_belt,/datum/scan_condition/black_hole,/datum/scan_condition/nebula,/datum/scan_condition/pulsar)

/datum/experiment/exploration_scan/random/site_type
	possible_random_site_types = list(/datum/exploration_site/asteroid_belt,/datum/exploration_site/uncharted_planet,/datum/exploration_site/junkyard)

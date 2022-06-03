// Both alarm_threshold and alarm_threshold_collection are lazily initialized. 
// The lazy initialization logic is handled by any proc that modifies values. They should return either itself or the new instance.
// Always reassign it to whatever variable references these datums.

/// Alarm threshold values used for air alarms. 
/// Could totally be an assoc list but more memory efficient and more functional this way.
/datum/alarm_threshold
	// All of these numbers should be positive.
	/// Minimum level of a number to flash yellow. Try and have this threshold be a non-lethal number.
	var/warning_min
	/// Minimum level of a number to flash red. Usually hazardous.
	var/hazard_min
	/// Maximum level of a number to flash yellow. Try and have this threshold be a non-lethal number.
	var/warning_max
	/// Maximum level of a number to flash red. Usually hazardous.
	var/hazard_max


/// Sets the alarm_threshold datum variables using one single proc.
/// This should be empty most of the time except on custom alarms.
/datum/alarm_threshold/New(adjust = FALSE, new_warning_min, new_hazard_min, new_warning_max, new_hazard_max)
	if(!adjust)
		return
	warning_min = new_warning_min
	warning_max = new_warning_max
	hazard_min = new_hazard_min
	hazard_max = new_hazard_max

/**
 * Checks whether a value has exceeded or is equal to the thresholds set.
 * 
 * Returns either:
 * [AIR_ALARM_THRESHOLD_SAFE], [AIR_ALARM_THRESHOLD_WARNING], or [AIR_ALARM_THRESHOLD_HAZARDOUS]
 * 
 * Arguments:
 * * checked_value - Value to be checked
 */
/datum/alarm_threshold/proc/check_value(checked_value)
	if(hazard_max != AIR_ALARM_THRESHOLD_IGNORE && checked_value >= hazard_max)
		return AIR_ALARM_THRESHOLD_HAZARDOUS
	if(hazard_min != AIR_ALARM_THRESHOLD_IGNORE && checked_value <= hazard_min)
		return AIR_ALARM_THRESHOLD_HAZARDOUS
	if(warning_min != AIR_ALARM_THRESHOLD_IGNORE && checked_value <= warning_min)
		return AIR_ALARM_THRESHOLD_WARNING
	if(warning_max != AIR_ALARM_THRESHOLD_IGNORE && checked_value >= warning_max)
		return AIR_ALARM_THRESHOLD_WARNING
	return AIR_ALARM_THRESHOLD_SAFE

/**
 * Copies our datum's threshold values to a target.
 * 
 * Arguments:
 * * [target][/datum/alarm_threshold] - Target datum
 */
/datum/alarm_threshold/proc/copy_to(datum/alarm_threshold/target)
	target.warning_min = warning_min
	target.hazard_min = hazard_min
	target.warning_max = warning_max
	target.hazard_max = hazard_max

/**
 * Set the value for the alarm threshold datum. Returns self so we can do lazy initialization very easily.
 * You should reassign it back to the variable most of the time.
 * Arguments:
 * * Identifier - The identifier corresponding to the variable that we want to set.
 * * new_value - The new value.
 */
/datum/alarm_threshold/proc/set_value(idenitifier, new_value)
	if(idenitifier & AIR_ALARM_THRESHOLD_WARNING_MIN)
		warning_min = new_value
	if(idenitifier & AIR_ALARM_THRESHOLD_HAZARD_MIN)
		hazard_min = new_value
	if(idenitifier & AIR_ALARM_THRESHOLD_WARNING_MAX)
		warning_max = new_value
	if(idenitifier & AIR_ALARM_THRESHOLD_HAZARD_MAX)
		hazard_max = new_value
	return src

/datum/alarm_threshold/universal

/datum/alarm_threshold/universal/set_value(identifier, new_value)
	var/datum/alarm_threshold/new_threshold = new
	copy_to(new_threshold)
	return new_threshold.set_value(identifier, new_value)

/// Collects, autogenerates, and manages creation of new alarm_threshold datums.
/datum/alarm_threshold_collection
	var/list/datum/alarm_threshold/thresholds

/datum/alarm_threshold_collection/New()
	thresholds = list()
	/// Pressure in kPa, corresponds to [/datum/gas_mixture/var/pressure].
	thresholds["pressure"] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/pressure]
	/// Temperatures in kelvin, corresponds to [/datum/gas_mixture/var/temperature].
	thresholds["temperature"] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/temperature]
	/// Gas partial pressure in kpa.
	for (var/datum/gas/gas_path as anything in subtypesof(/datum/gas))
		if(initial(gas_path.dangerous))
			thresholds[gas_path] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/dangerous_gas]
			continue
		thresholds[gas_path] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/normal_gas]
	thresholds[/datum/gas/oxygen] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/oxygen]

/datum/alarm_threshold_collection/Destroy()
	thresholds = null
	return ..()

/**
 * Check the value for a given gasmix.
 * Returns an assoc list of list[threshold_index] = danger level
 * 
 * Arguments:
 * * [gasmix][/datum/gas_mixture] - Gasmix instance to check
 */
/datum/alarm_threshold_collection/proc/check_value(datum/gas_mixture/gasmix)
	var/list/report = list()
	
	var/pressure = gasmix.return_pressure()
	var/total_moles = gasmix.total_moles()
	var/temperature = gasmix.return_temperature()
	
	report["temperature"] = thresholds["temperature"].check_value(temperature)
	report["pressure"] = thresholds["pressure"].check_value(pressure)

	for(var/gas_path in subtypesof(/datum/gas))
		var/partial_pressure = 0
		if(total_moles && gasmix.gases[gas_path]) //gas not in gasmix
			partial_pressure = (gasmix.gases[gas_path][MOLES] / total_moles) * pressure
		report[gas_path] = thresholds[gas_path].check_value(partial_pressure)
	
	return report

/**
 * Copies our threshold collection list to a target.
 * 
 * Arguments:
 * * [target][/datum/alarm_threshold] - Target datum
 */
/datum/alarm_threshold_collection/proc/copy_to(datum/alarm_threshold_collection/target)
	for(var/alarm_threshold in thresholds)
		// Honestly this check isnt necessary, we can pass everything by reference since currently
		// an older collection will be deleted once it's copied.
		// But this future proofs it in case someone wants to copy thresholds between collections.
		if(istype(thresholds[alarm_threshold], /datum/alarm_threshold/universal))
			target.thresholds[alarm_threshold] = thresholds[alarm_threshold]
		else
			target.thresholds[alarm_threshold] = new /datum/alarm_threshold
			thresholds[alarm_threshold].copy_to(target.thresholds[alarm_threshold])

/**
 * Modify the collection, and return self.
 * 
 * Arguments:
 * * index - The index in the list. Currently accepts "pressure", "temperature", and gas paths.
 * * identifier - identifier arg in [/datum/alarm_threshold/proc/set_value].
 * * new_value - new_value arg in [/datum/alarm_threshold/proc/set_value].
 */
/datum/alarm_threshold_collection/proc/set_value(index, identifier, new_value)
	if(index != "pressure" && index != "temperature" && !ispath(index, /datum/gas))
		return src
	thresholds[index] = thresholds[index].set_value(identifier, new_value)
	return src

/**
 * Resets one of our indices to the global one.
 * 
 * Arguments:
 * index - our [/datum/alarm_threshold_collection/var/list/thresholds] index to reset.
 */
/datum/alarm_threshold_collection/proc/reset_criteria(index)
	if(index == "pressure")
		thresholds["pressure"] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/pressure]
		return src

	if(index == "temperature")
		thresholds["temperature"] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/temperature]
		return src

	if(!ispath(index,/datum/gas))
		return src
	var/datum/gas/gas_criteria = index
	if(gas_criteria == /datum/gas/oxygen)
		thresholds[gas_criteria] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/oxygen]
	else if(initial(gas_criteria.dangerous))
		thresholds[gas_criteria] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/dangerous_gas]
	else
		thresholds[gas_criteria] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/normal_gas]
	return src

/**
 * Turns one of our indices to a nocheck universal threshold.
 * 
 * Arguments:
 * index - our [/datum/alarm_threshold_collection/var/list/thresholds] index to reset.
 */
/datum/alarm_threshold_collection/proc/kill_criteria(index)
	if(index != "pressure" && index != "temperature" && !ispath(index, /datum/gas))
		return src
	thresholds[index] = GLOB.alarm_thresholds[/datum/alarm_threshold/universal/no_checks]
	return src

/datum/alarm_threshold_collection/universal

/datum/alarm_threshold_collection/universal/set_value(index, identifier, new_value)
	if(index != "pressure" && index != "temperature" && !ispath(index, /datum/gas))
		return src
	var/datum/alarm_threshold_collection/new_thresholds = new
	copy_to(new_thresholds)
	return new_thresholds.set_value(index, identifier, new_value)

/datum/alarm_threshold_collection/universal/reset_criteria(index)
	if(index != "pressure" && index != "temperature" && !ispath(index, /datum/gas))
		return src
	var/datum/alarm_threshold_collection/new_thresholds = new
	copy_to(new_thresholds)
	return new_thresholds.reset_criteria(index)

/datum/alarm_threshold_collection/universal/kill_criteria(index)
	if(index != "pressure" && index != "temperature" && !ispath(index, /datum/gas))
		return src
	var/datum/alarm_threshold_collection/new_thresholds = new
	copy_to(new_thresholds)
	return new_thresholds.kill_criteria(index)

/// Returns a formatted static data of this one threshold, ready to be read by the UI.
/// ui_data in all but name and lack of UI
/datum/alarm_threshold/proc/return_info()
	return list(
		"warning_min" = round(warning_min,0.01),
		"hazard_min" = round(hazard_min),
		"warning_max" = round(warning_max),
		"hazard_max" = round(hazard_max),
	)

/// Returns a formatted data of our thresholds, ready to be read by the UI.
/// ui_data in all but name and lack of UI.
/datum/alarm_threshold_collection/proc/return_info()
	var/list/data = list()
	data["temperature"] = thresholds["temperature"].return_info()
	data["temperature"] += list(
		"threshold_name" = "Temperature", 
		"threshold_unit" = "K",
	)
	data["pressure"] = thresholds["pressure"].return_info()
	data["pressure"] += list(
		"threshold_name" = "Pressure", 
		"threshold_unit" = "kPa"
	)
	for (var/datum/gas/gas_path as anything in subtypesof(/datum/gas))
		data[gas_path] = thresholds[gas_path].return_info()
		data[gas_path] += list(
			"threshold_name" = initial(gas_path.name), 
			"threshold_unit" = "kPa",
		)
	return data

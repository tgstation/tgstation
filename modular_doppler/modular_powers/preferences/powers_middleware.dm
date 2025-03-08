/datum/preference_middleware/powers
	var/static/list/name_to_powers
	action_delegations = list(
		"give_power" = PROC_REF(give_power),
		"remove_power" = PROC_REF(remove_power),
	)

/datum/preference_middleware/powers/get_ui_data(mob/user)

	if(length(name_to_powers) != length(GLOB.all_powers))
		initialize_names_to_powers()

	var/list/data = list()

	var/list/thaumaturge = list()
	var/list/enigmatist = list()
	var/list/theologist = list()

	var/list/psyker = list()
	var/list/cultivator = list()
	var/list/aberrant = list()

	var/list/warfighter = list()
	var/list/expert = list()
	var/list/augmented = list()

	var/max_power_points = MAXIMUM_POWER_POINTS

	var/current_points = point_check()

	for(var/power_name in GLOB.all_powers)
		var/datum/power/power = GLOB.power_datum_instances[power_name]

		var/state
		var/word
		var/color
		var/powertype
		var/rootpower = null

		if(power.root_power == power.type)
			powertype = "crown"
		else if(power.advanced)
			powertype = "diamond"
			rootpower = power.root_power.name
		else
			powertype = ""
			rootpower = power.root_power.name

		if(preferences.powers[power.name])
			state = "bad"
			word = "Forget"
		else
			state = "good"
			word = "Learn"
			if((power.cost + current_points) > max_power_points)
				state = "transparent"
				word = "N/A"
				color = "0.5"
				rootpower = null
			else
				color = "1"

		var/final_list = list(list(
				"description" = power.desc,
				"name" = power.name,
				"cost" = power.cost,
				"state" = state,
				"word" = word,
				"color" = color,
				"powertype" = powertype,
				"rootpower" = rootpower
			))

		switch(power.power_type)
			if(TRAIT_PATH_SUBTYPE_THAUMATURGE)
				thaumaturge += final_list
			if(TRAIT_PATH_SUBTYPE_ENIGMATIST)
				enigmatist += final_list
			if(TRAIT_PATH_SUBTYPE_THEOLOGIST)
				theologist += final_list
			if(TRAIT_PATH_SUBTYPE_PSYKER)
				psyker += final_list
			if(TRAIT_PATH_SUBTYPE_CULTIVATOR)
				cultivator += final_list
			if(TRAIT_PATH_SUBTYPE_ABERRANT)
				aberrant += final_list
			if(TRAIT_PATH_SUBTYPE_WARFIGHTER)
				warfighter += final_list
			if(TRAIT_PATH_SUBTYPE_EXPERT)
				expert += final_list
			if(TRAIT_PATH_SUBTYPE_AUGMENTED)
				augmented += final_list


	data["total_power_points"] = max_power_points
	data["thaumaturge"] = thaumaturge
	data["enigmatist"] = enigmatist
	data["theologist"] = theologist
	data["psyker"] = psyker
	data["cultivator"] = cultivator
	data["aberrant"] = aberrant
	data["warfighter"] = warfighter
	data["expert"] = expert
	data["augmented"] = augmented
	data["power_points"] = point_check()

	return data

/datum/preference_middleware/powers/proc/initialize_names_to_powers()
	name_to_powers = list()
	for(var/power_name in GLOB.all_powers)
		var/datum/power/power = GLOB.power_datum_instances[power_name]
		name_to_powers[power.name] = power_name

/**
 * Gives a power to a character using the params list provided by tgui. Runs through multiple checks to ensure that the power can be learned, see respective procs for their description
 *
 * Always returns TRUE, ensuring the UI stays updated.
 */

/datum/preference_middleware/powers/proc/give_power(list/params, mob/user)
	var/datum/power/power = name_to_powers[params["power_name"]]
	var/max_points = MAXIMUM_POWER_POINTS

	if(preferences.powers)
		if(power.advanced && advanced_check(power))
			to_chat(user, span_boldwarning("[power.name] is an advanced power! You cannot cross-path with it!"))
			return TRUE

		if(root_check(power))
			to_chat(user, span_boldwarning("[power.name] is missing it's root power!"))
			return TRUE

		if((point_check() + power.cost) > max_points)
			return TRUE

		var/datum/power/power_datum = new power()

		if(power_datum.blacklist.len && blacklist_check(power_datum, user))
			return TRUE

		if(power_datum.required_powers.len && required_check(power_datum))
			to_chat(user, span_boldwarning("[power.name] is missing one or more of it's required powers!"))
			return TRUE

		qdel(power_datum)

	preferences.powers[power.name] = power

	return TRUE

/**
 * Remove Power
 *
 * Removes a power from a character using the params list provided by tgui. Recursively checks all learned powers for their root power, advanced power and required powers to make sure that they still pass all checks with said power removed.
 */

/datum/preference_middleware/powers/proc/remove_power(list/params)
	var/datum/power/power = name_to_powers[params["power_name"]]

	preferences.powers -= power.name

	for(var/power_name in preferences.powers)
		var/datum/power/powor = preferences.powers[power_name]

		if(powor.advanced && advanced_check(powor))
			preferences.powers -= powor.name
			continue

		if(root_check(powor))
			preferences.powers -= powor.name
			continue

		var/datum/power/power_datum = new powor()

		if(power_datum.required_powers.len && required_check(power_datum))
			return TRUE

		qdel(power_datum)


	return TRUE

/**
 * Advanced Power Check
 *
 * Gathers the advanced power's path, as well as the paths of all learned powers. If the list is longer than one, that means the user has cross-pathed, in which case the proc returns TRUE and the check fails. Otherwise, returns false and fails.
 */

/datum/preference_middleware/powers/proc/advanced_check(datum/power/power_check)
	var/list/types = list()
	types += get_path_type(power_check.power_type)

	for(var/power_name in preferences.powers)
		var/datum/power/power = preferences.powers[power_name]
		var/type_to_check = get_path_type(power.power_type)
		if(!(type_to_check in types))
			types += type_to_check

	if(types.len > 1)
		return TRUE

	else return FALSE

/**
 * Root Check
 *
 * Checks for a power's root power. If the power is a root power itself, the check immediately returns false, passing. If the power's root power is in the player's learned powers, it returns false, also passing. Otherwise, fails.
 */

/datum/preference_middleware/powers/proc/root_check(datum/power/power_check)

	if(power_check.root_power == power_check)
		return FALSE

	for(var/power_name in preferences.powers)
		var/datum/power/powah = preferences.powers[power_name]
		if(power_check.root_power == powah)
			return FALSE

	return TRUE

/**
 * Point Check
 *
 * Checks the total point value of a user's learned powers.
 */

/datum/preference_middleware/powers/proc/point_check()
	var/total_points = 0

	for(var/power_name in preferences.powers)
		var/datum/power/expensive_ass_power = preferences.powers[power_name]
		total_points += expensive_ass_power.cost

	return total_points

/**
 * Blacklist Check
 *
 * Checks if any of the user's learned powers are in a specific power's blacklist.
 */

/datum/preference_middleware/powers/proc/blacklist_check(datum/power/power_check, mob/user)
	for(var/power_name in preferences.powers)
		if(preferences.powers[power_name] in power_check.blacklist)
			to_chat(user, span_boldwarning("[power_name] is in [power_check]'s blacklist!"))
			return TRUE

	return FALSE

/**
 * Required Powers Check
 *
 * Cycles through a user's learned powers, and if that power is in the provided power's required_powers, increases the count by 1. If the count equals the length of the required_powers list, they have all the required powers, therefore the proc returns FALSE, meaning it passes. Otherwise, returns TRUE and fails.
 */

/datum/preference_middleware/powers/proc/required_check(datum/power/power_check)
	var/count = 0
	for(var/power_name in preferences.powers)
		var/datum/power/required_power = preferences.powers[power_name]
		if(required_power in power_check.required_powers)
			count++

	if(count == power_check.required_powers.len)
		return FALSE

	return TRUE

/datum/preferences/proc/sanitize_powers()
	var/powers_edited = FALSE
	for(var/power_name as anything in powers)
		if(!power_name)
			powers.Remove(power_name)
			powers_edited = TRUE
			continue

		var/datum/power/power = powers[power_name]
		power = new power()
		if(!(power.type in subtypesof(/datum/power)))
			powers.Remove(power_name)
			powers_edited = TRUE
		qdel(power)

	return powers_edited

/datum/asset/simple/powers
	assets = list(
		"gear.png" = 'modular_doppler/modular_powers/icons/ui/powers/gear.png',
		"heart.png" = 'modular_doppler/modular_powers/icons/ui/powers/heart.png',
		"seal.png" = 'modular_doppler/modular_powers/icons/ui/powers/seal.png'
	)

/datum/preference_middleware/powers/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/simple/powers),
	)

/proc/get_path_type(string)

	switch(string)

		if(TRAIT_PATH_SUBTYPE_THAUMATURGE, TRAIT_PATH_SUBTYPE_ENIGMATIST, TRAIT_PATH_SUBTYPE_THEOLOGIST)
			return TRAIT_PATH_SORCEROUS

		if(TRAIT_PATH_SUBTYPE_PSYKER, TRAIT_PATH_SUBTYPE_CULTIVATOR, TRAIT_PATH_SUBTYPE_ABERRANT)
			return TRAIT_PATH_RESONANT

		if(TRAIT_PATH_SUBTYPE_WARFIGHTER, TRAIT_PATH_SUBTYPE_EXPERT, TRAIT_PATH_SUBTYPE_AUGMENTED)
			return TRAIT_PATH_MORTAL

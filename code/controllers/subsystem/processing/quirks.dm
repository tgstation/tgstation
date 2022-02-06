#define EXP_ASSIGN_WAYFINDER 1200
#define RANDOM_QUIRK_BONUS 3
#define MINIMUM_RANDOM_QUIRKS 3
//Used to process and handle roundstart quirks
// - Quirk strings are used for faster checking in code
// - Quirk datums are stored and hold different effects, as well as being a vector for applying trait string
PROCESSING_SUBSYSTEM_DEF(quirks)
	name = "Quirks"
	init_order = INIT_ORDER_QUIRKS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 1 SECONDS

	var/list/quirks = list() //Assoc. list of all roundstart quirk datum types; "name" = /path/
	var/list/quirk_points = list() //Assoc. list of quirk names and their "point cost"; positive numbers are good traits, and negative ones are bad
	///An assoc list of quirks that can be obtained as a hardcore character, and their hardcore value.
	var/list/hardcore_quirks = list()

	/// A list of quirks that can not be used with each other. Format: list(quirk1,quirk2),list(quirk3,quirk4)
	var/static/list/quirk_blacklist = list(
		list("Blind","Nearsighted"),
		list("Jolly","Depression","Apathetic","Hypersensitive"),
		list("Ageusia","Vegetarian","Deviant Tastes", "Gamer"),
		list("Ananas Affinity","Ananas Aversion", "Gamer"),
		list("Alcohol Tolerance","Light Drinker"),
		list("Clown Enjoyer","Mime Fan"),
		list("Bad Touch", "Friendly"),
		list("Extrovert", "Introvert"),
	)

/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	get_quirks()
	return ..()

/// Returns the list of possible quirks
/datum/controller/subsystem/processing/quirks/proc/get_quirks()
	RETURN_TYPE(/list)
	if (!quirks.len)
		SetupQuirks()

	return quirks

/datum/controller/subsystem/processing/quirks/proc/SetupQuirks()
	// Sort by Positive, Negative, Neutral; and then by name
	var/list/quirk_list = sort_list(subtypesof(/datum/quirk), /proc/cmp_quirk_asc)

	for(var/type in quirk_list)
		var/datum/quirk/quirk_type = type

		if(initial(quirk_type.abstract_parent_type) == type)
			continue

		quirks[initial(quirk_type.name)] = quirk_type
		quirk_points[initial(quirk_type.name)] = initial(quirk_type.value)

		var/hardcore_value = initial(quirk_type.hardcore_value)

		if(!hardcore_value)
			continue
		hardcore_quirks[quirk_type] += hardcore_value

/datum/controller/subsystem/processing/quirks/proc/AssignQuirks(mob/living/user, client/cli)
	var/badquirk = FALSE
	for(var/quirk_name in cli.prefs.all_quirks)
		var/datum/quirk/Q = quirks[quirk_name]
		if(Q)
			if(user.add_quirk(Q))
				SSblackbox.record_feedback("nested tally", "quirks_taken", 1, list("[quirk_name]"))
		else
			stack_trace("Invalid quirk \"[quirk_name]\" in client [cli.ckey] preferences")
			cli.prefs.all_quirks -= quirk_name
			badquirk = TRUE
	if(badquirk)
		cli.prefs.save_character()

	// Assign wayfinding pinpointer granting quirk if they're new
	if(cli.get_exp_living(TRUE) < EXP_ASSIGN_WAYFINDER && !user.has_quirk(/datum/quirk/item_quirk/needswayfinder))
		var/datum/quirk/wayfinder = /datum/quirk/item_quirk/needswayfinder
		if(user.add_quirk(wayfinder))
			SSblackbox.record_feedback("nested tally", "quirks_taken", 1, list(initial(wayfinder.name)))

/*
 *Randomises the quirks for a specified mob
 */
/datum/controller/subsystem/processing/quirks/proc/randomise_quirks(mob/living/user)
	var/bonus_quirks = max((length(user.quirks) + rand(-RANDOM_QUIRK_BONUS, RANDOM_QUIRK_BONUS)), MINIMUM_RANDOM_QUIRKS)
	var/added_quirk_count = 0 //How many we've added
	var/list/quirks_to_add = list() //Quirks we're adding
	var/good_count = 0 //Maximum of 6 good perks
	var/score //What point score we're at
	///Cached list of possible quirks
	var/list/possible_quirks = quirks.Copy()
	//Create a random list of stuff to start with
	while(bonus_quirks > added_quirk_count)
		var/quirk = pick(possible_quirks) //quirk is a string
		if(quirk in quirk_blacklist) //prevent blacklisted
			possible_quirks -= quirk
			continue
		if(quirk_points[quirk] > 0)
			good_count++
		score += quirk_points[quirk]
		quirks_to_add += quirk
		possible_quirks -= quirk
		added_quirk_count++

	//But lets make sure we're balanced
	while(score > 0)
		if(!length(possible_quirks))//Lets not get stuck
			break
		var/quirk = pick(quirks)
		if(quirk in quirk_blacklist) //prevent blacklisted
			possible_quirks -= quirk
			continue
		if(!quirk_points[quirk] < 0)//negative only
			possible_quirks -= quirk
			continue
		good_count++
		score += quirk_points[quirk]
		quirks_to_add += quirk

	//And have benefits too
	while(score < 0 && good_count <= MAX_QUIRKS)
		if(!length(possible_quirks))//Lets not get stuck
			break
		var/quirk = pick(quirks)
		if(quirk in quirk_blacklist) //prevent blacklisted
			possible_quirks -= quirk
			continue
		if(!quirk_points[quirk] > 0) //positive only
			possible_quirks -= quirk
			continue
		good_count++
		score += quirk_points[quirk]
		quirks_to_add += quirk

	for(var/datum/quirk/quirk as anything in user.quirks)
		if(quirk.name in quirks_to_add) //Don't delete ones we keep
			quirks_to_add -= quirk.name //Already there, no need to add.
			continue
		user.remove_quirk(quirk.type) //these quirks are objects

	for(var/datum/quirk/quirk as anything in quirks_to_add)
		user.add_quirk(quirks[quirk]) //these are typepaths converted from string

/// Takes a list of quirk names and returns a new list of quirks that would
/// be valid.
/// If no changes need to be made, will return the same list.
/// Expects all quirk names to be unique, but makes no other expectations.
/datum/controller/subsystem/processing/quirks/proc/filter_invalid_quirks(list/quirks)
	var/list/new_quirks = list()
	var/list/positive_quirks = list()
	var/balance = 0

	var/list/all_quirks = get_quirks()

	for (var/quirk_name in quirks)
		var/datum/quirk/quirk = all_quirks[quirk_name]
		if (isnull(quirk))
			continue

		if (initial(quirk.mood_quirk) && CONFIG_GET(flag/disable_human_mood))
			continue

		var/blacklisted = FALSE

		for (var/list/blacklist as anything in quirk_blacklist)
			if (!(quirk in blacklist))
				continue

			for (var/other_quirk in blacklist)
				if (other_quirk in new_quirks)
					blacklisted = TRUE
					break

			if (blacklisted)
				break

		if (blacklisted)
			continue

		var/value = initial(quirk.value)
		if (value > 0)
			if (positive_quirks.len == MAX_QUIRKS)
				continue

			positive_quirks[quirk_name] = value

		balance += value
		new_quirks += quirk_name

	if (balance > 0)
		var/balance_left_to_remove = balance

		for (var/positive_quirk in positive_quirks)
			var/value = positive_quirks[positive_quirk]
			balance_left_to_remove -= value
			new_quirks -= positive_quirk

			if (balance_left_to_remove <= 0)
				break

	// It is guaranteed that if no quirks are invalid, you can simply check through `==`
	if (new_quirks.len == quirks.len)
		return quirks

	return new_quirks

#undef RANDOM_QUIRK_BONUS
#undef MINIMUM_RANDOM_QUIRKS

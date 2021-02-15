#define EXP_ASSIGN_WAYFINDER 1200
//Used to process and handle roundstart quirks
// - Quirk strings are used for faster checking in code
// - Quirk datums are stored and hold different effects, as well as being a vector for applying trait string
PROCESSING_SUBSYSTEM_DEF(quirks)
	name = "Quirks"
	init_order = INIT_ORDER_QUIRKS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 1 SECONDS

	var/list/quirks = list()		//Assoc. list of all roundstart quirk datum types; "name" = /path/
	var/list/quirk_points = list()	//Assoc. list of quirk names and their "point cost"; positive numbers are good traits, and negative ones are bad
	var/list/quirk_objects = list()	//A list of all quirk objects in the game, since some may process
	var/list/quirk_blacklist = list() //A list of quirks that can not be used with each other. Format: list(quirk1,quirk2),list(quirk3,quirk4)
	///An assoc list of quirks that can be obtained as a hardcore character, and their hardcore value.
	var/list/hardcore_quirks = list()

/datum/controller/subsystem/processing/quirks/Initialize(timeofday)
	if(!quirks.len)
		SetupQuirks()

	quirk_blacklist = list(list("Blind","Nearsighted"), \
							list("Jolly","Depression","Apathetic","Hypersensitive"), \
							list("Ageusia","Vegetarian","Deviant Tastes"), \
							list("Ananas Affinity","Ananas Aversion"), \
							list("Alcohol Tolerance","Light Drinker"), \
							list("Clown Fan","Mime Fan"), \
							list("Bad Touch", "Friendly"), \
							list("Extrovert", "Introvert"))
	return ..()

/datum/controller/subsystem/processing/quirks/proc/SetupQuirks()
	// Sort by Positive, Negative, Neutral; and then by name
	var/list/quirk_list = sortList(subtypesof(/datum/quirk), /proc/cmp_quirk_asc)

	for(var/V in quirk_list)
		var/datum/quirk/T = V
		quirks[initial(T.name)] = T
		quirk_points[initial(T.name)] = initial(T.value)

		var/hardcore_value = initial(T.hardcore_value)

		if(!hardcore_value)
			continue
		hardcore_quirks[T] += hardcore_value

/datum/controller/subsystem/processing/quirks/proc/AssignQuirks(mob/living/user, client/cli, spawn_effects)
	var/badquirk = FALSE
	for(var/V in cli.prefs.all_quirks)
		var/datum/quirk/Q = quirks[V]
		if(Q)
			user.add_quirk(Q, spawn_effects)
		else
			stack_trace("Invalid quirk \"[V]\" in client [cli.ckey] preferences")
			cli.prefs.all_quirks -= V
			badquirk = TRUE
	if(badquirk)
		cli.prefs.save_character()

	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		human.hardcore_survival_score = cli.prefs.hardcore_survival_score //Only do this if we actually asign quirks, to prevent sillicons etc from getting the points.

	// Assign wayfinding pinpointer granting quirk if they're new
	if(cli.get_exp_living(TRUE) < EXP_ASSIGN_WAYFINDER && !user.has_quirk(/datum/quirk/needswayfinder))
		user.add_quirk(/datum/quirk/needswayfinder, TRUE)

/datum/controller/subsystem/processing/quirks/proc/randomise_quirks(mob/living/user, bonus_points = 0)
	var/list/quirk_list = subtypesof(/datum/quirk)
	var/bonus_quirks = max((length(user.roundstart_quirks) + rand(-3,3)), 3)
	var/added_quirk_count
	var/list/quirks_to_add = list()
	var/loop_preventer = 10
	var/good_count = 0
	var/score
	//Create a random list of stuff to start with
	while(bonus_quirks < added_quirk_count)
		if(!loop_preventer)//Lets not get stuck
			break
		var/datum/quirk/quirk = pick(quirk_list)
		if((quirk.name in quirk_blacklist) && !(quirk == quirk)) //prevent blacklisted
			loop_preventer--
			continue
		if(quirk.value > 0)
			good_count++
		score += quirk.value
		quirks_to_add += quirk
		added_quirk_count++

	//But lets make sure we're balanced
	loop_preventer = 10
	while(score > 0)
		if(!loop_preventer)//Lets not get stuck
			break
		var/datum/quirk/quirk = pick(quirk_list)
		if((quirk.name in quirk_blacklist) && !(quirk == quirk)) //prevent blacklisted
			loop_preventer--
			continue
		if(!quirk.value > 0)
			loop_preventer--
			continue
		good_count++
		score += quirk.value
		quirks_to_add += quirk
	//And have benefits too
	loop_preventer = 10
	while(score < 0 && good_count <= 6)
		if(!loop_preventer)//Lets not get stuck
			break
		var/datum/quirk/quirk = pick(quirk_list)
		if((quirk.name in quirk_blacklist) && !(quirk == quirk)) //prevent blacklisted
			loop_preventer--
			continue
		if(!quirk.value > 0)
			loop_preventer--
			continue
		good_count++
		score += quirk.value
		quirks_to_add += quirk

	for(var/datum/quirk/quirk as anything in user.roundstart_quirks)
		if(quirk in quirks_to_add)//Don't delete ones we keep
			continue
		user.remove_quirk(quirk)

	for(var/datum/quirk/quirk as anything in quirks_to_add)
		user.add_quirk(quirk)

/datum/round_event_control/heart_attack
	name = "Random Heart Attack"
	typepath = /datum/round_event/heart_attack
	weight = 20
	max_occurrences = 2
	min_players = 40
	category = EVENT_CATEGORY_HEALTH
	description = "A random crewmember's heart gives out."
	///Candidates for recieving a healthy dose of heart disease
	var/list/heart_attack_candidates = list()
	///Number of candidates to be smote
	var/quantity = 1

/datum/round_event_control/heart_attack/canSpawnEvent()
	..()
	generate_candidates() //generating candidates and checking in canSpawnEvent prevents extreme edge case of there being the 40 minimum players, with all being inlligible for a heart attack, wasting the event
	if(length(heart_attack_candidates))
		return TRUE
	message_admins("An event tried to give someone a heart attack, but no candidates could be found.")
	return FALSE

/datum/round_event_control/heart_attack/admin_setup()
	if(!check_rights(R_FUN))
		return

	generate_candidates() //canSpawnEvent() is bypassed by admin_setup, so this makes sure that the candidates are still generated
	quantity = tgui_input_number(usr, "There are [length(heart_attack_candidates)] crewmembers eligible for a heart attack. Please select a number of people's days you wish to ruin.", "Shia Hato Atakku!", 1, length(heart_attack_candidates))

/**
 * Performs initial analysis of which living players are eligible to be selected for a heart attack
 *
 * Traverses player_list and checks entries against a series of initial reviews to see if they should even be considered for a heart attack,
 * and at what weight should they be eligible to recieve it. This does not check for anything that should "block" a heart attack, as that
 * is done during the event itself.
 */
/datum/round_event_control/heart_attack/proc/generate_candidates()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		if(candidate.stat == DEAD || HAS_TRAIT(candidate, TRAIT_CRITICAL_CONDITION) || !candidate.can_heartattack() || (/datum/disease/heart_failure in candidate.diseases) || candidate.undergoing_cardiac_arrest())
			continue
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER))//only crewmembers can get one, a bit unfair for some ghost roles and it wastes the event
			continue
		if(candidate.satiety <= -60 && !candidate.has_status_effect(/datum/status_effect/exercised)) //Multiple junk food items recently //No foodmaxxing for the achievement
			heart_attack_candidates[candidate] = 3
		else
			heart_attack_candidates[candidate] = 1

/datum/round_event/heart_attack
	///A list of prime candidates for heart attacking
	var/list/victims = list()
	///Number of heart attacks to distribute
	var/attacks_left = 1

/datum/round_event/heart_attack/start()
	var/datum/round_event_control/heart_attack/heart_attack_event = control

	attacks_left = heart_attack_event.quantity
	victims = heart_attack_event.heart_attack_candidates

	while(attacks_left > 0 && length(victims))
		if(attack_heart())
			attacks_left--

/**
 * Picks a victim from a list and attempts to give them a heart attack
 *
 * Performs a pick_weight on a list of potential victims. Once selected, the "winner"
 * will recieve heart disease. Returns TRUE if a heart attack is successfully given, and
 * FALSE if something blocks it (currently just the exercised status effect).
 * Arguments:
 * * victims - the list of people who have passed the initial heart attack candidacy checks (performed in the round event control)
 */
/datum/round_event/heart_attack/proc/attack_heart()
	var/mob/living/carbon/human/winner = pick_weight(victims)
	if(winner.has_status_effect(/datum/status_effect/exercised)) //Stuff that should "block" a heart attack rather than just deny eligibility for one goes here.
		winner.visible_message("[winner] grunts and clutches their chest for a moment, catching their breath.", "Your chest lurches in pain for a brief moment, which quickly fades. \
								You feel like you've just avoided a serious health disaster.", "You hear someone's breathing sharpen for a moment, followed by a sigh of relief.", 4)
		if(winner.client)
			winner.client.give_award(/datum/award/achievement/misc/healthy, winner)
		message_admins("[winner] has just survived a random heart attack!")
		victims -= winner
	else
		var/datum/disease/heart_disease = new /datum/disease/heart_failure()
		winner.ForceContractDisease(heart_disease, FALSE, TRUE)
		announce_to_ghosts(winner)
		victims -= winner
		return TRUE
	return FALSE

/datum/round_event_control/heart_attack
	name = "Random Heart Attack"
	typepath = /datum/round_event/heart_attack
	weight = 20
	max_occurrences = 2
	min_players = 40 // To avoid shafting lowpop
	category = EVENT_CATEGORY_HEALTH
	description = "A random crewmember's heart gives out."
	min_wizard_trigger_potency = 6
	max_wizard_trigger_potency = 7
	admin_setup = list(/datum/event_admin_setup/minimum_candidate_requirement/heart_attack, /datum/event_admin_setup/input_number/heart_attack)
	///Candidates for recieving a healthy dose of heart disease
	var/list/heart_attack_candidates = list()

/datum/round_event_control/heart_attack/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .
	generate_candidates() //generating candidates and checking in can_spawn_event prevents extreme edge case of there being the 40 minimum players, with all being ineligible for a heart attack, wasting the event
	if(length(heart_attack_candidates))
		return TRUE

/**
 * Performs initial analysis of which living players are eligible to be selected for a heart attack.
 *
 * Traverses player_list and checks entries against a series of reviews to see if they should even be considered for a heart attack,
 * and at what weight should they be eligible to recieve it. The check for whether or not a heart attack should be "blocked" by something is done
 * later, at the round_event level, so this proc mostly just checks users for whether or not a heart attack should be possible.
 */
/datum/round_event_control/heart_attack/proc/generate_candidates()
	heart_attack_candidates.Cut()
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
	var/quantity = 1


/datum/round_event/heart_attack/start()
	var/datum/round_event_control/heart_attack/heart_control = control
	victims += heart_control.heart_attack_candidates
	heart_control.heart_attack_candidates.Cut()

	while(quantity > 0 && length(victims))
		if(attack_heart())
			quantity--

/**
 * Picks a victim from a list and attempts to give them a heart attack
 *
 * Performs a pick_weight on a list of potential victims. Once selected, the "winner"
 * will recieve heart disease. Returns TRUE if a heart attack is successfully given, and
 * FALSE if something blocks it.
 */
/datum/round_event/heart_attack/proc/attack_heart()
	var/mob/living/carbon/human/winner = pick_weight(victims)
	if(winner.has_status_effect(/datum/status_effect/exercised)) //Stuff that should "block" a heart attack rather than just deny eligibility for one goes here.
		winner.visible_message(span_warning("[winner] grunts and clutches their chest for a moment, catching their breath."), span_medal("Your chest lurches in pain for a brief moment, which quickly fades. \
								You feel like you've just avoided a serious health disaster."), span_hear("You hear someone's breathing sharpen for a moment, followed by a sigh of relief."), 4)
		winner.playsound_local(get_turf(winner), 'sound/health/slowbeat.ogg', 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		winner.Stun(3 SECONDS)
		if(winner.client)
			winner.client.give_award(/datum/award/achievement/misc/healthy, winner)
		message_admins("[winner] has just survived a random heart attack!") //time to spawn them a trophy :)
		victims -= winner
	else
		var/datum/disease/heart_disease = new /datum/disease/heart_failure()
		winner.ForceContractDisease(heart_disease, FALSE, TRUE)
		announce_to_ghosts(winner)
		victims -= winner
		return TRUE
	return FALSE

/datum/event_admin_setup/minimum_candidate_requirement/heart_attack
	output_text = "There are no candidates eligible to recieve a heart attack!"

/datum/event_admin_setup/minimum_candidate_requirement/heart_attack/count_candidates()
	var/datum/round_event_control/heart_attack/heart_control = event_control
	heart_control.generate_candidates() //can_spawn_event() is bypassed by admin_setup, so this makes sure that the candidates are still generated
	return length(heart_control.heart_attack_candidates)

/datum/event_admin_setup/input_number/heart_attack
	input_text = "Please select how many people's days you wish to ruin."
	default_value = 0
	max_value = 90 //Will be overridden
	min_value = 0

/datum/event_admin_setup/input_number/heart_attack/prompt_admins()
	var/datum/round_event_control/heart_attack/heart_control = event_control
	max_value = length(heart_control.heart_attack_candidates)
	return ..()

/datum/event_admin_setup/input_number/heart_attack/apply_to_event(datum/round_event/heart_attack/event)
	event.quantity = chosen_value

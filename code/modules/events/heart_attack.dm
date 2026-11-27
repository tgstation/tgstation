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
	/// Keeps a running list of weakrefs of potential candidates
	/// Gets updated every time we check if the event can run
	var/list/datum/weakref/heart_attack_candidates = list()

/datum/round_event_control/heart_attack/can_spawn_event(players_amt, allow_magic = FALSE)
	return ..() && check_candidates() > 0

/// Returns number of potential candidates
/datum/round_event_control/heart_attack/proc/check_candidates()
	heart_attack_candidates = get_candidates()
	return length(heart_attack_candidates)

/**
 * Performs initial analysis of which living players are eligible to be selected for a heart attack.
 *
 * Traverses player_list and checks entries against a series of reviews to see if they should even be considered for a heart attack,
 * and at what weight should they be eligible to receive it. The check for whether or not a heart attack should be "blocked" by something is done
 * later, at the round_event level, so this proc mostly just checks users for whether or not a heart attack should be possible.
 */
/datum/round_event_control/heart_attack/proc/get_candidates()
	var/list/new_candidates = list()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.player_list))
		if(IS_UNCONSCIOUS_OR_CRIT(candidate) || !candidate.can_heartattack() || candidate.has_status_effect(/datum/status_effect/heart_attack) || candidate.undergoing_cardiac_arrest())
			continue
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER))//only crewmembers can get one, a bit unfair for some ghost roles and it wastes the event
			continue
		if(candidate.satiety <= -60 && !candidate.has_status_effect(/datum/status_effect/exercised)) //Multiple junk food items recently //No foodmaxxing for the achievement
			new_candidates[WEAKREF(candidate)] = 3
		else
			new_candidates[WEAKREF(candidate)] = 1
	return new_candidates

/datum/round_event/heart_attack
	///Number of heart attacks to distribute
	var/quantity = 1

/datum/round_event/heart_attack/start()
	var/datum/round_event_control/heart_attack/heart_control = control
	var/list/victims = list()
	for(var/datum/weakref/ref, weight in heart_control.heart_attack_candidates)
		var/mob/candidate = ref.resolve()
		if(!QDELETED(candidate))
			victims[candidate] = weight

	while(quantity > 0 && length(victims))
		var/mob/living/carbon/human/winner = pick_weight(victims)
		if(attack_heart(winner))
			quantity--
		victims -= winner

/**
 * Picks a victim from a list and attempts to give them a heart attack
 *
 * Performs a pick_weight on a list of potential victims. Once selected, the "winner"
 * will receive heart disease. Returns TRUE if a heart attack is successfully given, and
 * FALSE if something blocks it.
 */
/datum/round_event/heart_attack/proc/attack_heart(mob/living/carbon/human/winner)
	// Our fitness level can potentially block a heart attack outright.
	var/fitness_protection_probability = winner.mind?.get_skill_modifier(/datum/skill/athletics, SKILL_RANDS_MODIFIER)

	if(prob(fitness_protection_probability * 2)) //Stuff that should "block" a heart attack rather than just deny eligibility for one goes here.
		winner.visible_message(span_warning("[winner] grunts and clutches their chest for a moment, catching [winner.p_their()] breath."), span_medal("Your chest lurches in pain for a brief moment, which quickly fades. \
								You feel like you've just avoided a serious health disaster."), span_hear("You hear someone's breathing sharpen for a moment, followed by a sigh of relief."), 4)
		winner.playsound_local(get_turf(winner), 'sound/effects/health/slowbeat.ogg', 40, 0, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
		winner.Stun(3 SECONDS)
		if(winner.client)
			winner.client.give_award(/datum/award/achievement/misc/healthy, winner)
		message_admins("[winner] has just survived a random heart attack!") //time to spawn them a trophy :)
		return FALSE

	winner.apply_status_effect(/datum/status_effect/heart_attack)
	announce_to_ghosts(winner)
	return TRUE

/datum/event_admin_setup/minimum_candidate_requirement/heart_attack
	output_text = "There are no candidates eligible to receive a heart attack!"

/datum/event_admin_setup/minimum_candidate_requirement/heart_attack/count_candidates()
	var/datum/round_event_control/heart_attack/heart_control = event_control
	return heart_control.check_candidates()

/datum/event_admin_setup/input_number/heart_attack
	input_text = "Please select how many people's days you wish to ruin."
	default_value = 0
	max_value = 90 //Will be overridden
	min_value = 0

/datum/event_admin_setup/input_number/heart_attack/prompt_admins()
	var/datum/round_event_control/heart_attack/heart_control = event_control
	max_value = heart_control.check_candidates()
	return ..()

/datum/event_admin_setup/input_number/heart_attack/apply_to_event(datum/round_event/heart_attack/event)
	event.quantity = chosen_value

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
	generate_candidates()
	if(LAZYLEN(heart_attack_candidates))
		return TRUE
	return FALSE

/datum/round_event_control/heart_attack/admin_setup()
	if(!check_rights(R_FUN))
		return

	generate_candidates() //canSpawnEvent() is bypassed by admin_setup, so this makes sure that the candidates are still generated
	quantity = tgui_input_number(usr, "There are [length(heart_attack_candidates)] potential candidates. How many heart attacks would you like to give?", "Shia Hato Atakku!", 1, length(heart_attack_candidates))

/datum/round_event_control/heart_attack/proc/generate_candidates()
	for(var/mob/living/carbon/human/candidate in shuffle(GLOB.human_list)) //CHANGE THIS TO PLAYER LIST, CURRENTLY SET TO THIS FOR DEBUG
		if(candidate.stat == DEAD || HAS_TRAIT(candidate, TRAIT_CRITICAL_CONDITION) || !candidate.can_heartattack() || (/datum/disease/heart_failure in candidate.diseases) || candidate.undergoing_cardiac_arrest())
			continue //
		if(!(candidate.mind.assigned_role.job_flags & JOB_CREW_MEMBER))//only crewmembers can get one, a bit unfair for some ghost roles and it wastes the event
			continue //
		if(candidate.satiety <= -60 && !candidate.has_status_effect(/datum/status_effect/exercised)) //Multiple junk food items recently //No foodmaxxing for the achievement
			heart_attack_candidates[candidate] = 3
		else //
			heart_attack_candidates[candidate] = 1

/datum/round_event/heart_attack
	end_when = 10 //Ten extra chances for someone to be attacked.
	///A list of prime candidates for heart attacking
	var/list/victims = list()
	///Number of heart attacks to distribute
	var/attacks_left = 1

/datum/round_event/heart_attack/start()
	var/datum/round_event_control/heart_attack/heart_attack_event = control

	attacks_left = heart_attack_event.quantity
	end_when += attacks_left //The ten are there just for padding
	victims += heart_attack_event.heart_attack_candidates

/datum/round_event/heart_attack/tick()
	if(attack_heart(victims))
		attacks_left--
		if(attacks_left <= 0)
			activeFor = end_when //Skip to the end, we're done

/datum/round_event/heart_attack/proc/attack_heart(var/list/victims)
	var/mob/living/carbon/human/winner = pick_weight(victims)
	if(winner.has_status_effect(/datum/status_effect/exercised))
		winner.visible_message("[winner] grunts and clutches their chest for a moment, catching their breath.", "Your chest lurches in pain for a brief moment, which quickly fades. \
								You feel like you've just avoided a serious health disaster.", "You hear someone's breathing sharpen for a moment, followed by a sigh of relief.", 4)
	else
		var/datum/disease/heart_disease = new /datum/disease/heart_failure()
		winner.ForceContractDisease(heart_disease, FALSE, TRUE)
		return TRUE
	return FALSE

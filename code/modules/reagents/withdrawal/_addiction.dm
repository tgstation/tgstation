///base class for addiction, handles when you become addicted and what the effects of that are. By default you become addicted when you hit a certain threshold, and stop being addicted once you go below another one.
/datum/addiction
	///Name of this addiction
	var/name = "cringe code"
	///Higher threshold, when you start being addicted
	var/addiction_gain_threshold = 600
	///Lower threshold, when you stop being addicted
	var/addiction_loss_threshold = 400
	///Messages for each stage of addictions.
	var/list/withdrawal_stage_messages = list()

///Called when you gain addiction points somehow. Takes a mind as argument and sees if you gained the addiction
/datum/addiction/proc/on_gain_addiction_points(datum/mind/victim_mind)
	var/current_addiction_point_amount = victim_mind.addiction_points[type]
	if(current_addiction_point_amount < addiction_gain_threshold) //Not enough to become addicted
		return
	if(LAZYACCESS(victim_mind.active_addictions, type)) //Already addicted
		return
	become_addicted(victim_mind)


///Called when you become addicted
/datum/addiction/proc/become_addicted(datum/mind/victim_mind)
	LAZYSET(victim_mind.active_addictions, type, 1) //Start at first cycle.
	log_game("[key_name(victim_mind.current)] has become addicted to [name].")


///Called when you lose addiction poitns somehow. Takes a mind as argument and sees if you lost the addiction
/datum/addiction/proc/on_lose_addiction_points(datum/mind/victim_mind)
	var/current_addiction_point_amount = victim_mind.addiction_points[type]
	if(!LAZYACCESS(victim_mind.active_addictions, type)) //Not addicted
		return
	if(current_addiction_point_amount > addiction_loss_threshold) //Not enough to stop being addicted
		return
	lose_addiction(victim_mind)

/datum/addiction/proc/lose_addiction(datum/mind/victim_mind)
	SEND_SIGNAL(victim_mind.current, COMSIG_CLEAR_MOOD_EVENT, "[type]_addiction")
	to_chat(victim_mind.current, "<span class='notice'>You feel like you've gotten over your need for drugs.</span>")
	LAZYREMOVE(victim_mind.active_addictions, type)

/datum/addiction/proc/process_addiction(var/mob/living/carbon/affected_carbon)
	for(var/datum/reagent/possible_drug as anything in affected_carbon.reagents.reagent_list) //Go through the drugs in our system
		for(var/addiction in possible_drug.addiction_types) //And check all of their addiction types
			if(addiction == type && possible_drug.volume >= MIN_ADDICTION_REAGENT_AMOUNT) //If one of them matches, and we have enough of it in our system, we're good.
				LAZYSET(affected_carbon.mind.active_addictions, type, 1) //Keeps withdrawal at first cycle.
				return
	///One cycle is 2 seconds
	switch(LAZYACCESS(affected_carbon.mind.active_addictions, type))
		if(1 to 10)
			addiction_act_stage1(affected_carbon)
		if(10 to 20)
			addiction_act_stage2(affected_carbon)
		if(20 to 30)
			addiction_act_stage3(affected_carbon)

	LAZYADDASSOC(affected_carbon.mind.active_addictions, type, 1) //Next cycle!


/// Called when addiction hits stage1, see
/datum/addiction/proc/withdrawal_stage_1(var/mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_light, name)
	if(prob(30))
		to_chat(affected_carbon, "<span class='danger'>[withdrawal_stage_messages[1]]</span>")
	return

/// Called when addiction hits stage2,
/datum/addiction/proc/withdrawal_stage_2(var/mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_medium, name)
	if(prob(30))
		to_chat(affected_carbon, "<span class='danger'>[withdrawal_stage_messages[2]]</span>")
	return

/// Called when addiction hits stage3,
/datum/addiction/proc/withdrawal_stage_3(var/mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_severe, name)
	if(prob(30))
		to_chat(affected_carbon, "<span class='danger'>[withdrawal_stage_messages[3]]</span>")
	return

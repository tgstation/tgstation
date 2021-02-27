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
	///Rates at which you lose addiction (in units/second) if you are not on the drug at that time per stage
	var/addiction_loss_per_stage = list(0.5, 0.5, 1, 1.5)
	///Rate at which high sanity helps addiction loss
	var/high_sanity_addiction_loss = 2

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
		return FALSE
	if(current_addiction_point_amount > addiction_loss_threshold) //Not enough to stop being addicted
		return FALSE
	lose_addiction(victim_mind)
	return TRUE

/datum/addiction/proc/lose_addiction(datum/mind/victim_mind)
	SEND_SIGNAL(victim_mind.current, COMSIG_CLEAR_MOOD_EVENT, "[type]_addiction")
	to_chat(victim_mind.current, "<span class='notice'>You feel like you've gotten over your need for drugs.</span>")
	LAZYREMOVE(victim_mind.active_addictions, type)

/datum/addiction/proc/process_addiction(mob/living/carbon/affected_carbon, delta_time, times_fired)
	var/current_addiction_cycle = LAZYACCESS(affected_carbon.mind.active_addictions, type) //If this is null, we're not addicted
	var/on_drug_of_this_addiction = FALSE
	for(var/datum/reagent/possible_drug as anything in affected_carbon.reagents.reagent_list) //Go through the drugs in our system
		for(var/addiction in possible_drug.addiction_types) //And check all of their addiction types
			if(addiction == type && possible_drug.volume >= MIN_ADDICTION_REAGENT_AMOUNT) //If one of them matches, and we have enough of it in our system, we're not losing addiction
				if(current_addiction_cycle)
					LAZYSET(affected_carbon.mind.active_addictions, type, 1) //Keeps withdrawal at first cycle.
				on_drug_of_this_addiction = TRUE
				return

	var/withdrawal_stage

	switch(current_addiction_cycle)
		if(WITHDRAWAL_STAGE1_START_CYCLE to WITHDRAWAL_STAGE1_END_CYCLE)
			withdrawal_stage = 1
		if(WITHDRAWAL_STAGE2_START_CYCLE to WITHDRAWAL_STAGE2_END_CYCLE)
			withdrawal_stage = 2
		if(WITHDRAWAL_STAGE3_START_CYCLE to INFINITY)
			withdrawal_stage = 3
		else
			withdrawal_stage = 0

	if(!on_drug_of_this_addiction)
		if(affected_carbon.mind.remove_addiction_points(type, addiction_loss_per_stage[withdrawal_stage + 1] * delta_time)) //If true was returned, we lost the addiction!
			return

	if(!current_addiction_cycle) //Dont do the effects if were not on drugs
		return FALSE

	switch(current_addiction_cycle)
		if(WITHDRAWAL_STAGE1_START_CYCLE)
			withdrawal_enters_stage_1(affected_carbon)
		if(WITHDRAWAL_STAGE2_START_CYCLE)
			withdrawal_enters_stage_2(affected_carbon)
		if(WITHDRAWAL_STAGE3_START_CYCLE)
			withdrawal_enters_stage_3(affected_carbon)

	///One cycle is 2 seconds
	switch(withdrawal_stage)
		if(1)
			withdrawal_stage_1_process(affected_carbon, delta_time)
		if(2)
			withdrawal_stage_2_process(affected_carbon, delta_time)
		if(3)
			withdrawal_stage_3_process(affected_carbon, delta_time)

	LAZYADDASSOC(affected_carbon.mind.active_addictions, type, 1 * delta_time) //Next cycle!

/// Called when addiction enters stage 1
/datum/addiction/proc/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_light, name)

/// Called when addiction enters stage 2
/datum/addiction/proc/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_medium, name)

/// Called when addiction enters stage 3
/datum/addiction/proc/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_severe, name)


/// Called when addiction is in stage 1 every process
/datum/addiction/proc/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	if(DT_PROB(5, delta_time))
		to_chat(affected_carbon, "<span class='danger'>[withdrawal_stage_messages[1]]</span>")

/// Called when addiction is in stage 2 every process
/datum/addiction/proc/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	if(DT_PROB(10, delta_time) )
		to_chat(affected_carbon, "<span class='danger'>[withdrawal_stage_messages[2]]</span>")


/// Called when addiction is in stage 3 every process
/datum/addiction/proc/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	if(DT_PROB(15, delta_time))
		to_chat(affected_carbon, "<span class='danger'>[withdrawal_stage_messages[3]]</span>")

///base class for addiction, handles when you become addicted and what the effects of that are. By default you become addicted when you hit a certain threshold, and stop being addicted once you go below another one.

#define ADDICTION_SATIETY_TICKS 6
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
	///Time since last addiction dose was taken
	var/time_since_dose_began = 0
	///Addiction has been satiated from a higher withdrawal state
	var/addiction_satiated = FALSE

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


///Called when you lose addiction points somehow. Takes a mind as argument and sees if you lost the addiction
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
			if(addiction == type && possible_drug.volume > 0) //If addiction drug is in system
				if(time_since_dose_began >= ADDICTION_SATIETY_TICKS) // and it's been in their body for more than 6 consecutive seconds, they're satisfying their addiction
					if(!addiction_satiated && current_addiction_cycle > WITHDRAWAL_STAGE2_START_CYCLE) //only give the bonus if they've come down from a higher level
						addiction_satiated = TRUE
						addiction_satiated_enter(affected_carbon)
					if(current_addiction_cycle)
						LAZYSET(affected_carbon.mind.active_addictions, type, 0) //Keeps withdrawal at first cycle.
					on_drug_of_this_addiction = TRUE
				time_since_dose_began += delta_time
				return

	var/withdrawal_stage

	switch(current_addiction_cycle)
		if(WITHDRAWAL_STAGE0_START_CYCLE to WITHDRAWAL_STAGE0_END_CYCLE)
			withdrawal_stage = 0
		if(WITHDRAWAL_STAGE1_START_CYCLE to WITHDRAWAL_STAGE1_END_CYCLE)
			withdrawal_stage = 1
		if(WITHDRAWAL_STAGE2_START_CYCLE to WITHDRAWAL_STAGE2_END_CYCLE)
			withdrawal_stage = 2
		if(WITHDRAWAL_STAGE3_START_CYCLE to INFINITY)
			withdrawal_stage = 3

	if(!on_drug_of_this_addiction)
		time_since_dose_began = 0
		if(affected_carbon.mind.remove_addiction_points(type, addiction_loss_per_stage[withdrawal_stage + 1] * delta_time)) //If true was returned, we lost the addiction!
			return

	if(!current_addiction_cycle) //Dont do the effects if were not on drugs
		return FALSE

	switch(current_addiction_cycle)
		if(WITHDRAWAL_STAGE0_START_CYCLE)
			withdrawal_enters_stage_0(affected_carbon)
		if(WITHDRAWAL_STAGE1_START_CYCLE)
			withdrawal_enters_stage_1(affected_carbon)
		if(WITHDRAWAL_STAGE2_START_CYCLE)
			withdrawal_enters_stage_2(affected_carbon)
			addiction_satiated = FALSE //reset so they can get the addiction satiation enter after getting their fix
		if(WITHDRAWAL_STAGE3_START_CYCLE)
			withdrawal_enters_stage_3(affected_carbon)

	///One cycle is 2 seconds
	switch(withdrawal_stage)
		if(0)
			withdrawal_stage_0_process(affected_carbon, delta_time)
		if(1)
			withdrawal_stage_1_process(affected_carbon, delta_time)
		if(2)
			withdrawal_stage_2_process(affected_carbon, delta_time)
		if(3)
			withdrawal_stage_3_process(affected_carbon, delta_time)

	LAZYADDASSOC(affected_carbon.mind.active_addictions, type, 1 * delta_time) //Next cycle!

/// Called when addiciton enters stage 0
/datum/addiction/proc/withdrawal_enters_stage_0(mob/living/carbon/affected_carbon)
	/// Clear all withdrawal mood effects
	SEND_SIGNAL(affected_carbon, COMSIG_CLEAR_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_light, name)
	SEND_SIGNAL(affected_carbon, COMSIG_CLEAR_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_medium, name)
	SEND_SIGNAL(affected_carbon, COMSIG_CLEAR_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_severe, name)

/// Called when addiction enters stage 1
/datum/addiction/proc/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_light, name)

/// Called when addiction enters stage 2
/datum/addiction/proc/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_medium, name)

/// Called when addiction enters stage 3
/datum/addiction/proc/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction", /datum/mood_event/withdrawal_severe, name)

/// Called when addiction is first satiated from a withdrawal stage
/datum/addiction/proc/addiction_satiated_enter(mob/living/carbon/affected_carbon)
	SEND_SIGNAL(affected_carbon, COMSIG_ADD_MOOD_EVENT, "[type]_addiction_satiated", /datum/mood_event/addiction_satiated, name)

/// Called when addiction is in stage 0 every process, empty by default. Override in addiction procs
/datum/addiction/proc/withdrawal_stage_0_process(mob/living/carbon/affected_carbon, delta_time)

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

#undef ADDICTION_SATIETY_TICKS

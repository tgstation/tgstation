/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/

/datum/ai_controller
	///The mob this controller is controlling
	var/mob/living/controlled_mob
	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits
	///Current action being performed by the AI.
	var/datum/ai_behavior/list/current_ai_behaviors = list()
	///Current status of AI (OFF/ON/IDLE)
	var/ai_status

/datum/ai_controller/New(mob/living/assigned_mob)
	if(CreateController(assigned_mob) & AI_BEHAVIOR_INCOMPATIBLE)
		if(!controlled_mob) //If we're not attached to something destroy us.
			qdel(src)
		CRASH("[src] attached to [assigned_mob] but these are not compatible!")

	src.controlled_mob = assigned_mob
	set_ai_status(AI_STATUS_ON)

	RegisterSignal(controlled_mob, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)

///Abstract proc for initializing the controller's actions and other properties.
/datum/ai_controller/proc/CreateController(mob/living/new_mob)
	return


/// Generates a plan and see if our existing one is still valid.
/datum/ai_controller/process(delta_time)
	var/list/new_plan = generate_plan()
	for(var/key in current_ai_behaviors)
		if(current_ai_behaviors[key] != new_plan[key]) //Not the same plan
			current_ai_behaviors[key]?.finish_execution(FALSE) //Cancel the previous one.
			current_ai_behaviors[key] = new_plan[key]
			current_ai_behaviors[key].behavior_key = key //Re-assign the correct key
			current_ai_behaviors[key].start_execution()

///This is where you decide what actions are taken by the AI in parallel. By default this means AI_BEHAVIOR_MOVEMENT and AI_BEHAVIOR_ACTION.
/datum/ai_controller/proc/generate_plan()
	return list()

///Cancels all currently active actions, for when for they are no longer needed.
/datum/ai_controller/proc/cancel_behaviors()
	for(var/key in current_ai_behaviors)
		var/datum/ai_behavior/ai_behavior = current_ai_behaviors[key]
		ai_behavior.finish_execution(FALSE)

///This proc handles changing ai status, and starts/stops processing if required.
/datum/ai_controller/proc/set_ai_status(new_ai_status)
	if(ai_status == new_ai_status)
		return FALSE //no change

	ai_status = new_ai_status
	switch(ai_status)
		if(AI_STATUS_ON)
			START_PROCESSING(SSai_controllers, src)
		if(AI_STATUS_OFF)
			STOP_PROCESSING(SSai_controllers, src)
			cancel_behaviors()

/datum/ai_controller/proc/on_sentience_gained()
	UnregisterSignal(controlled_mob, COMSIG_MOB_LOGIN)
	set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(controlled_mob, COMSIG_MOB_LOGOUT, .proc/on_sentience_lost)


/datum/ai_controller/proc/on_sentience_lost()
	UnregisterSignal(controlled_mob, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_ON) //Can't do anything while player is connected
	RegisterSignal(controlled_mob, COMSIG_MOB_LOGIN, .proc/on_sentience_gained)



/*
thinkspace:addtimer
[MOVEMENT] = random_wander()
[ACTION] = fire_gun()



*/
